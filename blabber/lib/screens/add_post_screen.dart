import 'dart:io';
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

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // API endpoint
      Uri uri = Uri.parse('https://kovacscsabi.moriczcloud.hu/api/posts');

      // Create multipart request
      var request = http.MultipartRequest('POST', uri);

      // Add text field
      request.fields['content'] = _contentController.text;

      // Add image if selected
      if (_imageFile != null) {
        var fileExtension =
            path.extension(_imageFile!.path).replaceAll('.', '');
        var contentType = 'image/$fileExtension';

        request.files.add(
          await http.MultipartFile.fromPath(
            'media_url',
            _imageFile!.path,
            contentType: MediaType.parse(contentType),
          ),
        );
      }

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
      // Add any headers if needed
      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      // Send the request
      var response = await request.send();

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Nem sikerült feltölteni a posztat. Kód: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
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
