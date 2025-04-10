import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:blabber/models/identicard.dart';

import '../services/identicard_service.dart';



// Define colors
final accentColor = Color.fromRGBO(255, 32, 78, 1);
final baseColor = Color.fromRGBO(0, 34, 77, 1);
final textColor = Colors.white;

class EditIdenticardScreen extends StatefulWidget {


  const EditIdenticardScreen();

  @override
  State<EditIdenticardScreen> createState() => _EditIdenticardScreenState();
}

class _EditIdenticardScreenState extends State<EditIdenticardScreen> {
  final _formKey = GlobalKey<FormState>();
  final IdenticardService _service = IdenticardService();
  bool _exists = false;
  bool _isLoading = true;

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _profilePictureController = TextEditingController();
  final _coverPhotoController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _birthdayController = TextEditingController();
  final _pronounsController = TextEditingController();
  final _relationshipStatusController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _currentWorkplaceController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _portfolioLinkController = TextEditingController();
  final _themePrimaryColorController = TextEditingController();
  final _themeAccentColorController = TextEditingController();
  final _themeBgColorController = TextEditingController();
  final _themeTextColorController = TextEditingController();

  List<String> _skills = [];
  List<String> _hobbies = [];
  Map<String, String> _messagingApps = {};
  Map<String, String> _socialHandles = {};
  List<Map<String, String>> _previousWorkplaces = [];
  List<Map<String, String>> _education = [];
  List<Map<String, String>> _certifications = [];
  List<Map<String, String>> _languages = [];
  String? _profileVisibility;

  @override
  void initState() {
    super.initState();
    _loadData();
  }
// Helper method to parse JSON arrays from strings with proper type handling
  List<dynamic> parseJsonArray(dynamic value) {
    if (value == null || value == "null") {
      return [];
    }

    if (value is List) {
      return value;
    }

    try {
      final decoded = jsonDecode(value.toString());
      if (decoded is List) {
        return decoded;
      }
      return [];
    } catch (e) {
      print('Error parsing JSON array: $e');
      return [];
    }
  }

// Helper method to parse JSON maps from strings
  Map<String, String> parseJsonMap(dynamic value) {
    if (value == null || value == "null") {
      return {};
    }

    if (value is Map) {
      return Map<String, String>.from(
          value.map((key, val) => MapEntry(key.toString(), val?.toString() ?? '')));
    }

    try {
      final decoded = jsonDecode(value.toString());
      if (decoded is Map) {
        return Map<String, String>.from(
            decoded.map((key, val) => MapEntry(key.toString(), val?.toString() ?? '')));
      }
      return {};
    } catch (e) {
      print('Error parsing JSON map: $e');
      return {};
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final exists = await _service.checkExists();
      setState(() => _exists = exists);
      if (exists) {
        final identicard = await _service.getIdenticard();
        setState(() {
          _nameController.text = identicard.name ?? '';
          _profilePictureController.text = identicard.profilePicture ?? '';
          _coverPhotoController.text = identicard.coverPhoto ?? '';
          _bioController.text = identicard.bio ?? '';
          _locationController.text = identicard.location ?? '';
          _birthdayController.text = identicard.birthday?.toIso8601String().split('T')[0] ?? '';
          _pronounsController.text = identicard.pronouns ?? '';
          _relationshipStatusController.text = identicard.relationshipStatus ?? '';
          _phoneController.text = identicard.phone ?? '';
          _websiteController.text = identicard.website ?? '';
          _currentWorkplaceController.text = identicard.currentWorkplace ?? '';
          _jobTitleController.text = identicard.jobTitle ?? '';
          _portfolioLinkController.text = identicard.portfolioLink ?? '';
          _themePrimaryColorController.text = identicard.themePrimaryColor ?? '';
          _themeAccentColorController.text = identicard.themeAccentColor ?? '';
          _themeBgColorController.text = identicard.themeBgColor ?? '';
          _themeTextColorController.text = identicard.themeTextColor ?? '';

          // Parse string fields first
          final skills = parseJsonArray(identicard.skills);
          final hobbies = parseJsonArray(identicard.hobbies);
          _skills = skills.isNotEmpty ? skills.map((s) => s.toString()).toList() : [];
          _hobbies = hobbies.isNotEmpty ? hobbies.map((h) => h.toString()).toList() : [];

          // Handle map fields
          _messagingApps = parseJsonMap(identicard.messagingApps);
          _socialHandles = parseJsonMap(identicard.socialHandles);

          // Handle complex objects
          final previousWorkplaces = parseJsonArray(identicard.previousWorkplaces);
          final education = parseJsonArray(identicard.education);
          final certifications = parseJsonArray(identicard.certifications);
          final languages = parseJsonArray(identicard.languages);

          _previousWorkplaces = previousWorkplaces.isNotEmpty
              ? previousWorkplaces.map((w) => Map<String, String>.from(
              w.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
          )).toList()
              : [];

          _education = education.isNotEmpty
              ? education.map((e) => Map<String, String>.from(
              e.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
          )).toList()
              : [];

          _certifications = certifications.isNotEmpty
              ? certifications.map((c) => Map<String, String>.from(
              c.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
          )).toList()
              : [];

          _languages = languages.isNotEmpty
              ? languages.map((l) => Map<String, String>.from(
              l.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''))
          )).toList()
              : [];

          _profileVisibility = identicard.profileVisibility ?? 'public';
        });
      } else {
        _profileVisibility = 'public'; // Default value if no Identicard exists
      }
    } catch (e) {
      print('Detailed error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final identicard = Identicard(
        name: _nameController.text.isEmpty ? null : _nameController.text,
        profilePicture: _profilePictureController.text.isEmpty ? null : _profilePictureController.text,
        coverPhoto: _coverPhotoController.text.isEmpty ? null : _coverPhotoController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        birthday: _birthdayController.text.isEmpty ? null : DateTime.parse(_birthdayController.text),
        pronouns: _pronounsController.text.isEmpty ? null : _pronounsController.text,
        relationshipStatus: _relationshipStatusController.text.isEmpty ? null : _relationshipStatusController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        messagingApps: _messagingApps.isEmpty ? null : _messagingApps,
        website: _websiteController.text.isEmpty ? null : _websiteController.text,
        socialHandles: _socialHandles.isEmpty ? null : _socialHandles,
        currentWorkplace: _currentWorkplaceController.text.isEmpty ? null : _currentWorkplaceController.text,
        jobTitle: _jobTitleController.text.isEmpty ? null : _jobTitleController.text,
        previousWorkplaces: _previousWorkplaces.isEmpty ? null : _previousWorkplaces,
        education: _education.isEmpty ? null : _education,
        certifications: _certifications.isEmpty ? null : _certifications,
        languages: _languages.isEmpty ? null : _languages,
        portfolioLink: _portfolioLinkController.text.isEmpty ? null : _portfolioLinkController.text,
        skills: _skills.isEmpty ? null : _skills,
        hobbies: _hobbies.isEmpty ? null : _hobbies,
        themePrimaryColor: _themePrimaryColorController.text.isEmpty ? null : _themePrimaryColorController.text,
        themeAccentColor: _themeAccentColorController.text.isEmpty ? null : _themeAccentColorController.text,
        themeBgColor: _themeBgColorController.text.isEmpty ? null : _themeBgColorController.text,
        themeTextColor: _themeTextColorController.text.isEmpty ? null : _themeTextColorController.text,
        profileVisibility: _profileVisibility,
      );
      try {
        if (_exists) {
          await _service.updateIdenticard(identicard);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Identicard updated successfully')),
          );
        } else {
          await _service.addIdenticard(identicard);
          setState(() => _exists = true); // Mark as existing after adding
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Identicard added successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: accentColor, width: 2),
          ),
          color: baseColor,
          elevation: 0,
        ),
      ),
      child: Scaffold(
        backgroundColor: baseColor,
        appBar: AppBar(
          title: Text('Edit Identicard'),
          backgroundColor: baseColor,
          foregroundColor: textColor,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildPersonalInformationSection(),
                SizedBox(height: 20),
                _buildContactInformationSection(),
                SizedBox(height: 20),
                _buildWorkAndEducationSection(),
                SizedBox(height: 20),
                _buildSkillsAndInterestsSection(),
                SizedBox(height: 20),
                _buildThemeSettingsSection(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: accentColor),
                  child: Text('Save', style: TextStyle(color: textColor)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInformationSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Personal Information', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLength: 255,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _profilePictureController,
              decoration: InputDecoration(labelText: 'Profile Picture URL', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLength: 255,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _coverPhotoController,
              decoration: InputDecoration(labelText: 'Cover Photo URL', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLength: 255,
              validator: (value) => value != null && value.length > 255 ? 'Max 255 characters' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Bio', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLines: 3,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLength: 255,
              validator: (value) => value != null && value.length > 255 ? 'Max 255 characters' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _birthdayController,
              decoration: InputDecoration(labelText: 'Birthday (YYYY-MM-DD)', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (picked != null) _birthdayController.text = picked.toIso8601String().split('T')[0];
              },
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  try {
                    DateTime.parse(value);
                  } catch (e) {
                    return 'Invalid date format';
                  }
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _pronounsController,
              decoration: InputDecoration(labelText: 'Pronouns', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLength: 50,
              validator: (value) => value != null && value.length > 50 ? 'Max 50 characters' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _relationshipStatusController,
              decoration: InputDecoration(labelText: 'Relationship Status', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLength: 50,
              validator: (value) => value != null && value.length > 50 ? 'Max 50 characters' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInformationSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Contact Information', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLength: 20,
              validator: (value) => value != null && value.length > 20 ? 'Max 20 characters' : null,
            ),
            SizedBox(height: 10),
            KeyValueListInput(
              initialItems: _messagingApps,
              onChanged: (newMap) => setState(() => _messagingApps = newMap),
              keyLabel: 'App Name',
              valueLabel: 'Handle',
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _websiteController,
              decoration: InputDecoration(labelText: 'Website', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLength: 255,
              validator: (value) => value != null && value.length > 255 ? 'Max 255 characters' : null,
            ),
            SizedBox(height: 10),
            KeyValueListInput(
              initialItems: _socialHandles,
              onChanged: (newMap) => setState(() => _socialHandles = newMap),
              keyLabel: 'Platform',
              valueLabel: 'Handle',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkAndEducationSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Work and Education', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextFormField(
              controller: _currentWorkplaceController,
              decoration: InputDecoration(labelText: 'Current Workplace', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLength: 255,
              validator: (value) => value != null && value.length > 255 ? 'Max 255 characters' : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _jobTitleController,
              decoration: InputDecoration(labelText: 'Job Title', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLength: 255,
              validator: (value) => value != null && value.length > 255 ? 'Max 255 characters' : null,
            ),
            SizedBox(height: 10),
            StructuredListInput(
              initialItems: _previousWorkplaces.map((item) => Map<String, String>.from(item)).toList(),
              fields: ['company', 'position', 'duration'],
              title: 'Workplaces',
              onChanged: (newList) => setState(() => _previousWorkplaces = newList),
            ),
            SizedBox(height: 10),
            StructuredListInput(
              initialItems: _education.map((item) => Map<String, String>.from(item)).toList(),
              fields: ['institution', 'degree', 'year'],
              title: 'Education',
              onChanged: (newList) => setState(() => _education = newList),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsAndInterestsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Skills and Interests', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            StructuredListInput(
              initialItems: _skills.map((skill) => {'skill': skill}).toList(),
              fields: ['skill'],
              title: 'Skills',
              onChanged: (newList) => setState(() => _skills = newList.map((item) => item['skill']!).toList()),
            ),
            SizedBox(height: 10),
            StructuredListInput(
              initialItems: _certifications.map((item) => Map<String, String>.from(item)).toList(),
              fields: ['name', 'issuer', 'date'],
              title: 'Certifications',
              onChanged: (newList) => setState(() => _certifications = newList),
            ),
            SizedBox(height: 10),
            StructuredListInput(
              initialItems: _languages.map((item) => Map<String, String>.from(item)).toList(),
              fields: ['language', 'proficiency'],
              onChanged: (newList) => setState(() => _languages = newList),
              title: 'Languages',
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _portfolioLinkController,
              decoration: InputDecoration(labelText: 'Portfolio Link', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              maxLength: 255,
              validator: (value) => value != null && value.length > 255 ? 'Max 255 characters' : null,
            ),
            SizedBox(height: 10),
            StructuredListInput(
              initialItems: _hobbies.map((hobby) => {'hobby': hobby}).toList(),
              fields: ['hobby'],
              title: 'Hobbies',
              onChanged: (newList) => setState(() => _hobbies = newList.map((item) => item['hobby']!).toList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSettingsSection() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme Settings', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            TextFormField(
              controller: _themePrimaryColorController,
              decoration: InputDecoration(labelText: 'Primary Color (#RRGGBB)', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              validator: (value) {
                if (value != null && value.isNotEmpty && !RegExp(r'^#([A-Fa-f0-9]{6})$').hasMatch(value)) {
                  return 'Invalid hex color';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _themeAccentColorController,
              decoration: InputDecoration(labelText: 'Accent Color (#RRGGBB)', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              validator: (value) {
                if (value != null && value.isNotEmpty && !RegExp(r'^#([A-Fa-f0-9]{6})$').hasMatch(value)) {
                  return 'Invalid hex color';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _themeBgColorController,
              decoration: InputDecoration(labelText: 'Background Color (#RRGGBB)', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              validator: (value) {
                if (value != null && value.isNotEmpty && !RegExp(r'^#([A-Fa-f0-9]{6})$').hasMatch(value)) {
                  return 'Invalid hex color';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: _themeTextColorController,
              decoration: InputDecoration(labelText: 'Text Color (#RRGGBB)', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              validator: (value) {
                if (value != null && value.isNotEmpty && !RegExp(r'^#([A-Fa-f0-9]{6})$').hasMatch(value)) {
                  return 'Invalid hex color';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _profileVisibility,
              decoration: InputDecoration(labelText: 'Profile Visibility', labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
              dropdownColor: baseColor,
              items: ['public', 'private'].map((v) => DropdownMenuItem(value: v, child: Text(v, style: TextStyle(color: textColor)))).toList(),
              onChanged: (value) => setState(() => _profileVisibility = value),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom widget for key-value pairs
class KeyValueListInput extends StatefulWidget {
  final Map<String, String> initialItems;
  final Function(Map<String, String>) onChanged;
  final String keyLabel;
  final String valueLabel;

  const KeyValueListInput({
    required this.initialItems,
    required this.onChanged,
    required this.keyLabel,
    required this.valueLabel,
    super.key,
  });

  @override
  State<KeyValueListInput> createState() => _KeyValueListInputState();
}

class _KeyValueListInputState extends State<KeyValueListInput> {
  late Map<String, String> items;

  @override
  void initState() {
    super.initState();
    items = Map.from(widget.initialItems);
  }

  void _addItem() async {
    final keyController = TextEditingController();
    final valueController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add ${widget.keyLabel}', style: TextStyle(color: textColor)),
        backgroundColor: baseColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: keyController,
              decoration: InputDecoration(labelText: widget.keyLabel, labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
            ),
            TextField(
              controller: valueController,
              decoration: InputDecoration(labelText: widget.valueLabel, labelStyle: TextStyle(color: textColor)),
              style: TextStyle(color: textColor),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (keyController.text.isNotEmpty && valueController.text.isNotEmpty) {
                setState(() {
                  items[keyController.text] = valueController.text;
                  widget.onChanged(items);
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add', style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${widget.keyLabel}s', style: TextStyle(color: textColor)),
        ...items.entries.map((e) => ListTile(
          title: Text('${e.key}: ${e.value}', style: TextStyle(color: textColor)),
          trailing: IconButton(
            icon: Icon(Icons.delete, color: accentColor),
            onPressed: () {
              setState(() {
                items.remove(e.key);
                widget.onChanged(items);
              });
            },
          ),
        )),
        TextButton(
          onPressed: _addItem,
          child: Text('Add ${widget.keyLabel}', style: TextStyle(color: accentColor)),
        ),
      ],
    );
  }
}

// Custom widget for structured lists with global styling
class StructuredListInput extends StatefulWidget {
  final List<Map<String, String>> initialItems;
  final List<String> fields;
  final String? title;
  final Function(List<Map<String, String>>) onChanged;

  const StructuredListInput({
    required this.initialItems,
    required this.fields,
    required this.onChanged,
    this.title,
    super.key,
  });

  @override
  State<StructuredListInput> createState() => _StructuredListInputState();
}

class _StructuredListInputState extends State<StructuredListInput> {
  late List<Map<String, String>> items;

  @override
  void initState() {
    super.initState();
    items = List.from(widget.initialItems);
  }

  void _addItem() async {
    final controllers = {for (var field in widget.fields) field: TextEditingController()};
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Item', style: TextStyle(color: textColor)),
        backgroundColor: baseColor,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.fields
                .map((field) => Padding(
              padding: EdgeInsets.only(bottom: 5), // Spacing in dialog
              child: TextField(
                controller: controllers[field],
                decoration: InputDecoration(labelText: field, labelStyle: TextStyle(color: textColor)),
                style: TextStyle(color: textColor),
              ),
            ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              final newItem = {for (var field in widget.fields) field: controllers[field]!.text};
              if (newItem.values.every((v) => v.isNotEmpty)) {
                setState(() {
                  items.add(newItem);
                  widget.onChanged(items);
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add', style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0), // Consistent padding
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.8), // Slightly transparent base color for contrast
        border: Border.all(color: accentColor, width: 1), // Subtle border
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title ?? widget.fields.join(', '), // Use custom title if provided, else default to fields            style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          ...items.asMap().entries.map((entry) => Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0),
            child: ListTile(
              title: Text(
                widget.fields.length == 1 ? entry.value[widget.fields[0]]! : entry.value.toString(),
                style: TextStyle(color: textColor),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: accentColor),
                onPressed: () {
                  setState(() {
                    items.removeAt(entry.key);
                    widget.onChanged(items);
                  });
                },
              ),
            ),
          )),
          TextButton(
            onPressed: _addItem,
            child: Text('Add Item', style: TextStyle(color: accentColor)),
          ),
        ],
      ),
    );
  }
}