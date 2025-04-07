import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart';

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
    'messaging_apps': {}, // default as Map
    'website': '',
    'social_handles': {}, // default as Map
    'current_workplace': '',
    'job_title': '',
    'previous_workplaces': [], // default as List
    'education': {}, // default as Map
    'skills': <String>[],
    'certifications': {}, // default as Map
    'languages': {}, // default as Map
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

        // Process problematic fields individually:

        // messaging_apps should be a Map
        if (cardData['messaging_apps'] == null ||
            cardData['messaging_apps'] == "null") {
          _formData['messaging_apps'] = {};
        } else {
          try {
            _formData['messaging_apps'] = jsonDecode(cardData['messaging_apps']);
          } catch (e) {
            _formData['messaging_apps'] = cardData['messaging_apps'];
          }
        }

        // social_handles should be a Map
        if (cardData['social_handles'] == null ||
            cardData['social_handles'] == "null") {
          _formData['social_handles'] = {};
        } else {
          try {
            _formData['social_handles'] = jsonDecode(cardData['social_handles']);
          } catch (e) {
            _formData['social_handles'] = cardData['social_handles'];
          }
        }

        // skills should be a List<String>
        if (cardData['skills'] == null || cardData['skills'] == "null") {
          _formData['skills'] = <String>[];
        } else if (cardData['skills'] is List) {
          _formData['skills'] = List<String>.from(cardData['skills']);
        } else if (cardData['skills'] is String) {
          try {
            _formData['skills'] = List<String>.from(jsonDecode(cardData['skills']));
          } catch (e) {
            _formData['skills'] =
                cardData['skills'].toString().split(',').map((e) => e.trim()).toList();
          }
        }

        // hobbies should be a List<String>
        if (cardData['hobbies'] == null || cardData['hobbies'] == "null") {
          _formData['hobbies'] = <String>[];
        } else if (cardData['hobbies'] is List) {
          _formData['hobbies'] = List<String>.from(cardData['hobbies']);
        } else if (cardData['hobbies'] is String) {
          try {
            _formData['hobbies'] = List<String>.from(jsonDecode(cardData['hobbies']));
          } catch (e) {
            _formData['hobbies'] =
                cardData['hobbies'].toString().split(',').map((e) => e.trim()).toList();
          }
        }

        // previous_workplaces should be a List (e.g., list of maps)
        if (cardData['previous_workplaces'] == null ||
            cardData['previous_workplaces'] == "null") {
          _formData['previous_workplaces'] = [];
        } else if (cardData['previous_workplaces'] is String) {
          try {
            _formData['previous_workplaces'] =
                jsonDecode(cardData['previous_workplaces']);
          } catch (e) {
            _formData['previous_workplaces'] = cardData['previous_workplaces'];
          }
        } else {
          _formData['previous_workplaces'] = cardData['previous_workplaces'];
        }

        // education should be a Map
        if (cardData['education'] == null || cardData['education'] == "null") {
          _formData['education'] = {};
        } else if (cardData['education'] is String) {
          try {
            _formData['education'] = jsonDecode(cardData['education']);
          } catch (e) {
            _formData['education'] = cardData['education'];
          }
        } else {
          _formData['education'] = cardData['education'];
        }

        // certifications should be a Map
        if (cardData['certifications'] == null ||
            cardData['certifications'] == "null") {
          _formData['certifications'] = {};
        } else if (cardData['certifications'] is String) {
          try {
            _formData['certifications'] = jsonDecode(cardData['certifications']);
          } catch (e) {
            _formData['certifications'] = cardData['certifications'];
          }
        } else {
          _formData['certifications'] = cardData['certifications'];
        }

        // languages should be a Map
        if (cardData['languages'] == null || cardData['languages'] == "null") {
          _formData['languages'] = {};
        } else if (cardData['languages'] is String) {
          try {
            _formData['languages'] = jsonDecode(cardData['languages']);
          } catch (e) {
            _formData['languages'] = cardData['languages'];
          }
        } else {
          _formData['languages'] = cardData['languages'];
        }

        // For all other fields not specifically processed, update only if valid.
        final specialKeys = {
          'messaging_apps',
          'social_handles',
          'skills',
          'hobbies',
          'previous_workplaces',
          'education',
          'certifications',
          'languages'
        };

        cardData.forEach((key, value) {
          if (!specialKeys.contains(key)) {
            if (value != null && value != "null") {
              _formData[key] = value;
            }
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
                  _formData[field] =
                      '#${selectedColor.value.toRadixString(16).substring(2)}';
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
                initialValue: (_formData['skills'] is List)
                    ? _formData['skills'].join(', ')
                    : '',
                decoration: const InputDecoration(
                  labelText: 'Skills (comma-separated)',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _formData['skills'] = value
                    ?.split(',')
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
                        Color(int.parse(
                            '0xFF${_formData['theme_primary_color'].substring(1)}')),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(int.parse(
                            '0xFF${_formData['theme_primary_color'].substring(1)}'))
                      ),
                      child: const Text('Primary Color'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showColorPicker(
                        'theme_accent_color',
                        Color(int.parse(
                            '0xFF${_formData['theme_accent_color'].substring(1)}')),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(int.parse(
                            '0xFF${_formData['theme_accent_color'].substring(1)}'))
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
