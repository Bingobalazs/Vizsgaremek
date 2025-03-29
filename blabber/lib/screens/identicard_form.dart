import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';


// UNSED



class IdCardForm extends StatefulWidget {
  const IdCardForm({Key? key}) : super(key: key);

  @override
  _IdCardFormState createState() => _IdCardFormState();
}

class _IdCardFormState extends State<IdCardForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isExisting = false;
  
  final Map<String, dynamic> _formData = {
    'username': '',
    'email': '',
    'name': '',
    'profile_picture': '',
    'cover_photo': '',
    'bio': '',
    'location': '',
    'birthday': '',
    'pronouns': '',
    'relationship_status': '',
    'phone': '',
    'messaging_apps': '{}',
    'website': '',
    'social_handles': '{}',
    'current_workplace': '',
    'job_title': '',
    'previous_workplaces': '{}',
    'education': '{}',
    'skills': <String>[],
    'certifications': '{}',
    'languages': '{}',
    'portfolio_link': '',
    'hobbies': <String>[],
    'theme_primary_color': '#000000',
    'theme_accent_color': '#000000',
    'theme_bg_color': '#ffffff',
    'theme_text_color': '#000000',
    'profile_visibility': 'public'
  };

  @override
  void initState() {
    super.initState();
    _checkExistingCard();
  }

  Future<void> _checkExistingCard() async {
    try {
      final response = await http.get(
        Uri.parse('https://kovacscsabi.moriczcloud.hu/api/identicard/check')
      );
      
      _isExisting = json.decode(response.body);
      
      if (_isExisting) {
        final dataResponse = await http.get(
          Uri.parse('https://kovacscsabi.moriczcloud.hu/api/identicard/json')
        );
        final cardData = json.decode(dataResponse.body);
        
        setState(() {
          _formData.addAll(cardData);
          if (cardData['skills'] != null) {
            _formData['skills'] = List<String>.from(cardData['skills']);
          }
          if (cardData['hobbies'] != null) {
            _formData['hobbies'] = List<String>.from(cardData['hobbies']);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading data'))
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    
    final url = _isExisting
        ? 'https://kovacscsabi.moriczcloud.hu/api/identicard/update'
        : 'https://kovacscsabi.moriczcloud.hu/api/identicard/add';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(_formData)
      );
      
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isExisting 
              ? 'Card updated successfully!' 
              : 'Card created successfully!'
            )
          )
        );
        if (!_isExisting) setState(() => _isExisting = true);
      } else {
        throw Exception('Failed to submit form');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error submitting form'))
      );
    }
  }

  void _showColorPicker(String field, Color initialColor) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color selectedColor = initialColor;
        return AlertDialog(
          title: Text('Pick a ${field.replaceAll('_', ' ')}'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                selectedColor = color;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  _formData[field] = '#${selectedColor.value.toRadixString(16).substring(2)}';
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isExisting ? 'Modify IDCard' : 'Create IDCard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: _formData['username'],
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _formData['username'] = value,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: _formData['email'],
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) => _formData['email'] = value,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: _formData['bio'],
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onSaved: (value) => _formData['bio'] = value,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                initialValue: _formData['skills'].join(', '),
                decoration: const InputDecoration(
                  labelText: 'Skills (comma-separated)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _formData['skills'] = value?.split(',')
                    .map((e) => e.trim())
                    .where((e) => e.isNotEmpty)
                    .toList() ?? [],
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showColorPicker(
                        'theme_primary_color',
                        Color(int.parse('0xFF${_formData['theme_primary_color'].substring(1)}'))
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(
                          int.parse('0xFF${_formData['theme_primary_color'].substring(1)}')
                        )
                      ),
                      child: const Text('Primary Color'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showColorPicker(
                        'theme_accent_color',
                        Color(int.parse('0xFF${_formData['theme_accent_color'].substring(1)}'))
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(
                          int.parse('0xFF${_formData['theme_accent_color'].substring(1)}')
                        )
                      ),
                      child: const Text('Accent Color'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _formData['profile_visibility'],
                decoration: const InputDecoration(
                  labelText: 'Profile Visibility',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'public', child: Text('Public')),
                  DropdownMenuItem(value: 'private', child: Text('Private')),
                ],
                onChanged: (value) {
                  setState(() => _formData['profile_visibility'] = value);
                },
              ),
              const SizedBox(height: 24),
              
              ElevatedButton(
                onPressed: _submitForm,
                child: Text(_isExisting ? 'Update IDCard' : 'Create IDCard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}