import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AddPostScreen extends StatefulWidget {
  const AddPostScreen({Key? key}) : super(key: key);

  @override
  _AddPostScreenState createState() => _AddPostScreenState();
}
final accentColor = Color.fromRGBO(255, 32, 78, 1);
final baseColor = Color.fromRGBO(0, 34, 77, 1);

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  Future _pickImage() async {
    final XFile? pickedFile =
    await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create Dio instance
      final dio = Dio();

      // API endpoint
      String url = 'https://kovacscsabi.moriczcloud.hu/api/posts';

      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      bool _loading = false;
      String? _errorMessage;

      if (token == null) {
        setState(() {
          _errorMessage = 'Nem vagy bejelentkezve!';
          _loading = false;
        });
        return;
      }

      // Set headers
      dio.options.headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data',
      };

      // Create form data
      FormData formData = FormData();

      // Add text content
      formData.fields.add(MapEntry('content', _contentController.text));

      // Add image if selected
      if (_imageFile != null) {
        // Get file extension and ensure it's valid
        var fileExtension = path.extension(_imageFile!.path).replaceAll('.', '').toLowerCase();

        // If the extension is empty or invalid, default to a safe value
        if (fileExtension.isEmpty || !['jpeg', 'jpg', 'png', 'gif'].contains(fileExtension)) {
          // Try to determine from the path or default to jpeg
          if (_imageFile!.path.toLowerCase().contains('png')) {
            fileExtension = 'png';
          } else if (_imageFile!.path.toLowerCase().contains('gif')) {
            fileExtension = 'gif';
          } else if (_imageFile!.path.toLowerCase().contains('jpg') ||
              _imageFile!.path.toLowerCase().contains('jpeg')) {
            fileExtension = 'jpeg';
          } else {
            fileExtension = 'jpeg'; // Default to jpeg if unknown
          }
        }

        // Create a multipart file
        String fileName = _imageFile!.path.split('/').last;

        // For web compatibility, we need different approaches
        if (kIsWeb) {
          // For web, we need to use Uint8List
          Uint8List imageBytes = await _imageFile!.readAsBytes();
          formData.files.add(MapEntry(
            'media_url',
            MultipartFile.fromBytes(
              imageBytes,
              filename: fileName,
              contentType: MediaType.parse('image/$fileExtension'),
            ),
          ));
        } else {
          // For Android/iOS
          formData.files.add(MapEntry(
            'media_url',
            await MultipartFile.fromFile(
              _imageFile!.path,
              filename: fileName,
              contentType: MediaType.parse('image/$fileExtension'),
            ),
          ));
        }

        print('File path: ${_imageFile!.path}');
        print('Content type: image/$fileExtension');
      }

      try {
        // Send the request
        final response = await dio.post(
          url,
          data: formData,
          onSendProgress: (sent, total) {
            // You can use this to show upload progress if needed
            print('Upload progress: ${(sent / total * 100).toStringAsFixed(2)}%');
          },
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Poszt feltöltve!')),
          );

          // Clear form
          _contentController.clear();
          setState(() {
            _imageFile = null;
          });

          // Optionally navigate back or to feed
          Navigator.pop(context);
        } else {
          // Error
          print('Error response: ${response.data}');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Nem sikerült feltölteni a posztot. Kód: ${response.statusCode}'),
            ),
          );
        }
      } on DioException catch (e) {
        print('Dio exception: ${e.message}');
        print('Response data: ${e.response?.data}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba történt: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Új poszt létrehozása'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _submitPost,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Post', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  hintText: "Milyen faszságon töröd a fejed??",
                  border: InputBorder.none,
                ),
                maxLines: 10,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Azért valamit írj be, ha már mindenképp posztolni akarsz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (_imageFile != null) ...[
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.cancel,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        setState(() {
                          _imageFile = null;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(
                    Icons.image,
                    color: Colors.white,
                ),
                label: const Text('Fénykép'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }
}
