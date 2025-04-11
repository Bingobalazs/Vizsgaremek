import 'dart:async';
import 'dart:typed_data'; // Needed for web image bytes
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // For MediaType
import 'dart:io'; // Used ONLY for mobile image display

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  // --- Configuration ---
  final String apiUrl = 'https://kovacscsabi.moriczcloud.hu/api/posts';
  final String bearerTokenKey = 'auth_token';
  final String apiTextFieldName = 'content';
  final String apiImageFieldName = 'media_url';

  // --- UI Colors ---
  final Color accentColor = const Color.fromRGBO(255, 32, 78, 1);
  final Color baseColor = const Color.fromRGBO(0, 34, 77, 1);

  // --- State Variables ---
  final _textController = TextEditingController();
  XFile? _selectedImage; // Use XFile for cross-platform compatibility
  Uint8List? _selectedImageBytes; // Store bytes for web display/upload
  bool _isLoading = false;
  String? _errorMessage;
  String? _validationError; // Specifically for image validation

  final _imagePicker = ImagePicker();
  final int _maxImageSizeBytes = 5 * 1024 * 1024; // 5 MB
  final List<String> _allowedMimeTypes = [
    'image/jpeg',
    'image/png',
    'image/jpg',
    'image/gif'
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // --- Image Selection Logic ---
  Future<void> _pickImage() async {
    setState(() {
      _validationError = null; // Clear previous validation errors
      _errorMessage = null;
    });
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery, // Or ImageSource.camera
      );

      if (pickedFile != null) {
        final validationResult = await _validateImage(pickedFile);
        if (validationResult == null) {
          // Read bytes once for web/upload efficiency
          final bytes = await pickedFile.readAsBytes();
          setState(() {
            _selectedImage = pickedFile;
            _selectedImageBytes = bytes; // Store bytes
            _validationError = null;
          });
        } else {
          setState(() {
            _selectedImage = null;
            _selectedImageBytes = null;
            _validationError = validationResult; // Show validation error
          });
        }
      }
    } catch (e) {
      debugPrint("Nem sikerült kép kiválasztása: $e");
      setState(() {
        _errorMessage = "Nem sikerült kép kiválasztása: $e";
        _validationError = null; // Clear validation error if general error occurs
      });
    }
  }

  // --- Image Validation Logic ---
  Future<String?> _validateImage(XFile imageFile) async {
    // 1. Size Check
    final int fileSize = await imageFile.length();
    if (fileSize > _maxImageSizeBytes) {
      return 'Túl nagy kép (Max: ${_maxImageSizeBytes ~/ (1024 * 1024)} MB)';
    }

    // 2. MIME Type Check
    final String? mimeType = imageFile.mimeType?.toLowerCase(); // Use mimeType provided by image_picker
    if (mimeType == null || !_allowedMimeTypes.contains(mimeType)) {
      // Get file extension as a fallback check (less reliable)
      final String extension = imageFile.name.split('.').last.toLowerCase();
      final List<String> allowedExtensions = ['jpeg', 'png', 'jpg', 'gif'];
      if (!allowedExtensions.contains(extension)) {
        return 'Nem megfelelő képformátum. Elfogadott: JPEG, PNG, GIF';
      }
      // If mimeType is null but extension seems okay, cautiously proceed
      // but log a warning. Production apps might want stricter checks.
      debugPrint("Warning: Could not determine MIME type for ${imageFile.name}, proceeding based on extension '$extension'.");
    }

    return null; // Validation passed
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _selectedImageBytes = null;
      _validationError = null; // Clear error when image is removed
    });
  }

  // --- Post Submission Logic ---
  Future<void> _submitPost() async {
    if (_textController.text.trim().isEmpty) {
      setState(() => _errorMessage = 'A bejegyzés szövege nem lehet üres.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _validationError = null;
    });

    String? token;
    try {
      final prefs = await SharedPreferences.getInstance();
      token = prefs.getString(bearerTokenKey);

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found. Please log in.');
      }

      // Use MultipartRequest for potential file upload
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // Set Headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json'; // Good practice

      // Add Text Field
      request.fields[apiTextFieldName] = _textController.text.trim();

      // Add Image File (if selected and bytes available)
      if (_selectedImage != null && _selectedImageBytes != null) {
        final http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
          apiImageFieldName, // API field name for the image
          _selectedImageBytes!,
          filename: _selectedImage!.name, // Send filename
          contentType: MediaType.parse(_selectedImage!.mimeType ?? 'application/octet-stream'), // Send MIME type
        );
        request.files.add(multipartFile);
      }

      // Send Request
      final http.StreamedResponse streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);


      // Handle Response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        if (mounted) { // Check if widget is still in the tree
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Post created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Clear form and optionally navigate back
          _textController.clear();
          setState(() {
            _selectedImage = null;
            _selectedImageBytes = null;
            _isLoading = false;
          });
          // Consider Navigator.pop(context); if this screen was pushed
        }
      } else {
        // Error
        String errorMsg = 'Nem sikerült létrehozni.  Hibakód: ${response.statusCode}';
        // Try to parse error message from API response body if available
        // Example assumes JSON error like: {"message": "Error details"}
        try {
          final responseBody = response.body;
          // Attempt to decode JSON - replace with your actual API error structure
          // final decodedBody = jsonDecode(responseBody);
          // if (decodedBody is Map && decodedBody.containsKey('message')) {
          //   errorMsg = 'Failed to create post: ${decodedBody['message']}';
          // } else {
          errorMsg = 'Nem sikerült létrehozni: ${response.statusCode}\nResponse: ${responseBody.substring(0, (responseBody.length > 100) ? 100 : responseBody.length)}...'; // Show snippet
          // }
        } catch (e) {
          // Ignore decoding errors, use default message
          errorMsg = 'Nem sikerült létrehozni: ${response.statusCode}. Ismeretlen hiba történt.';
        }

        throw Exception(errorMsg); // Throw exception to be caught below
      }

    } catch (e) {
      debugPrint("Bejegyzés küldési hiba: $e");
      if (mounted) {
        setState(() {
          _errorMessage = "Hiba történt: $e";
          _isLoading = false;
        });
      }
    } finally {
      // Ensure loading state is always reset, even on unexpected errors
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: baseColor, // Lighter background
      appBar: AppBar(
        title: const Text('Új bejegyzés'),
        backgroundColor: baseColor,
        foregroundColor: Colors.white, // Make title text white
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Text Input ---
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Mit szeretnél írni?',
                labelText: 'Bejegyzés szövege',
                border: OutlineInputBorder(
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: baseColor, width: 2.0),

                ),
                floatingLabelStyle: TextStyle(color: baseColor),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              minLines: 3,
              maxLength: 500, // Optional: Add a character limit
              textInputAction: TextInputAction.newline,
            ),
            const SizedBox(height: 16.0),

            // --- Image Picker Button ---
            ElevatedButton.icon(
              icon: const Icon(Icons.image_search),
              label: const Text('Kép hozzáadása'),

              onPressed: _isLoading ? null : _pickImage,
            ),
            const SizedBox(height: 8.0),

            // --- Image Validation Error Display ---
            if (_validationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  _validationError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),


            // --- Image Preview ---
            if (_selectedImage != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  Container(
                    constraints: const BoxConstraints(
                      maxHeight: 250, // Limit preview height
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ClipRRect( // Clip image to rounded corners
                      borderRadius: BorderRadius.circular(8.0),
                      child: _buildImagePreview(),
                    ),
                  ),
                  // Remove Image Button
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.black54,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 16,
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: _isLoading ? null : _removeImage,
                        tooltip: 'Kép törlése',
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 24.0),

            // --- General Error Message Display ---
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),

            // --- Submit Button ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),

                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              onPressed: _isLoading ? null : _submitPost,
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Text('Bejegyzés létrehozása'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to build image preview conditionally for web/mobile
  Widget _buildImagePreview() {
    if (_selectedImageBytes != null) {
      // Use bytes for both platforms now, simpler and avoids dart:io import issues directly in build
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover, // Adjust fit as needed
        width: double.infinity, // Take available width
        errorBuilder: (context, error, stackTrace) => const Center(
            child: Text('Nem lehet betölteni az előnézetet', textAlign: TextAlign.center)
        ),
      );
    } else {
      // Fallback if bytes aren't loaded for some reason (shouldn't happen with current logic)
      return const Center(child: Text('Nincs kép kiválasztav, vagy nem lehet betölteni az előnézetet'));
    }

    // --- Previous platform-specific approach (kept for reference) ---
    // if (kIsWeb && _selectedImage != null) {
    //   // WEB: Use Image.network with the blob URL from XFile.path
    //   return Image.network(
    //     _selectedImage!.path,
    //     fit: BoxFit.cover,
    //     width: double.infinity,
    //      errorBuilder: (context, error, stackTrace) => const Center(child: Text('Could not load image preview')),
    //   );
    // } else if (!kIsWeb && _selectedImage != null) {
    //   // MOBILE: Use Image.file
    //   // IMPORTANT: Requires importing 'dart:io'
    //   return Image.file(
    //     File(_selectedImage!.path), // Create File object
    //     fit: BoxFit.cover,
    //     width: double.infinity,
    //     errorBuilder: (context, error, stackTrace) => const Center(child: Text('Could not load image preview')),
    //   );
    // } else {
    //   return const SizedBox.shrink(); // No image selected
    // }
  }
}