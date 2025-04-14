

import 'package:blabber/models/identicard.dart';
import 'package:blabber/services/identicard_service.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intl/intl.dart'; // For date formatting

class IdenticardScreen extends StatefulWidget {
  const IdenticardScreen({Key? key}) : super(key: key);

  @override
  _IdenticardScreenState createState() => _IdenticardScreenState();
}

class _IdenticardScreenState extends State<IdenticardScreen> {
  bool isLoading = true;
  bool exists = false;
  Identicard? identicard;
  String? token;

  // Controllers for simple fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController birthdayController = TextEditingController();
  final TextEditingController pronounsController = TextEditingController();
  final TextEditingController relationshipStatusController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController websiteController = TextEditingController();
  final TextEditingController currentWorkplaceController = TextEditingController();
  final TextEditingController jobTitleController = TextEditingController();
  final TextEditingController portfolioLinkController = TextEditingController();

  // State variables for complex fields
  Map<String, String> messagingApps = {};
  Map<String, String> socialHandles = {};
  List<Workplace> previousWorkplaces = [];
  List<Education> education = [];
  List<String> skills = [];
  List<Certification> certifications = [];
  Map<String, String> languages = {};
  List<String> hobbies = [];

  // Color fields
  Color primaryColor = Colors.blue;
  Color accentColor = Colors.yellow;
  Color bgColor = Colors.white;
  Color textColor = Colors.black;

  String profileVisibility = 'public';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('auth_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No authentication token found')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      exists = await IdenticardService.checkIdenticardExists(token!);
      if (exists) {
        identicard = await IdenticardService.getIdenticard(token!);
        if (identicard != null) {
          _populateFields();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _populateFields() {
    nameController.text = identicard!.name ?? '';
    usernameController.text = identicard!.username ?? '';
    bioController.text = identicard!.bio ?? '';
    locationController.text = identicard!.location ?? '';
    birthdayController.text = identicard!.birthday ?? '';
    pronounsController.text = identicard!.pronouns ?? '';
    relationshipStatusController.text = identicard!.relationshipStatus ?? '';
    phoneController.text = identicard!.phone ?? '';
    websiteController.text = identicard!.website ?? '';
    currentWorkplaceController.text = identicard!.currentWorkplace ?? '';
    jobTitleController.text = identicard!.jobTitle ?? '';
    portfolioLinkController.text = identicard!.portfolioLink ?? '';

    if (identicard!.messagingApps != null) {
      messagingApps = Map<String, String>.from(jsonDecode(identicard!.messagingApps!));
    }
    if (identicard!.socialHandles != null) {
      socialHandles = Map<String, String>.from(jsonDecode(identicard!.socialHandles!));
    }
    if (identicard!.previousWorkplaces != null) {
      previousWorkplaces = (jsonDecode(identicard!.previousWorkplaces!) as List)
          .map((item) => Workplace.fromJson(item))
          .toList();
    }
    if (identicard!.education != null) {
      education = (jsonDecode(identicard!.education!) as List)
          .map((item) => Education.fromJson(item))
          .toList();
    }
    if (identicard!.skills != null) {
      skills = List<String>.from(identicard!.skills!);
    }
    if (identicard!.certifications != null) {
      certifications = (jsonDecode(identicard!.certifications!) as List)
          .map((item) => Certification.fromJson(item))
          .toList();
    }
    if (identicard!.languages != null) {
      languages = Map<String, String>.from(jsonDecode(identicard!.languages!));
    }
    if (identicard!.hobbies != null) {
      hobbies = List<String>.from(identicard!.hobbies!);
    }
    if (identicard!.themePrimaryColor != null) {
      primaryColor = Color(int.parse(identicard!.themePrimaryColor!.substring(1), radix: 16) + 0xFF000000);
    }
    if (identicard!.themeAccentColor != null) {
      accentColor = Color(int.parse(identicard!.themeAccentColor!.substring(1), radix: 16) + 0xFF000000);
    }
    if (identicard!.themeBgColor != null) {
      bgColor = Color(int.parse(identicard!.themeBgColor!.substring(1), radix: 16) + 0xFF000000);
    }
    if (identicard!.themeTextColor != null) {
      textColor = Color(int.parse(identicard!.themeTextColor!.substring(1), radix: 16) + 0xFF000000);
    }
    profileVisibility = identicard!.profileVisibility ?? 'public';
  }

  Future<void> _saveData() async {
    final data = {
      'name': nameController.text,
      'username': usernameController.text,
      'bio': bioController.text,
      'location': locationController.text,
      'birthday': birthdayController.text,
      'pronouns': pronounsController.text,
      'relationship_status': relationshipStatusController.text,
      'phone': phoneController.text,
      'website': websiteController.text,
      'current_workplace': currentWorkplaceController.text,
      'job_title': jobTitleController.text,
      'portfolio_link': portfolioLinkController.text,
      'messaging_apps': jsonEncode(messagingApps),
      'social_handles': jsonEncode(socialHandles),
      'previous_workplaces': jsonEncode(previousWorkplaces.map((wp) => wp.toJson()).toList()),
      'education': jsonEncode(education.map((ed) => ed.toJson()).toList()),
      'skills': skills.isNotEmpty ? skills : null,
      'certifications': jsonEncode(certifications.map((cert) => cert.toJson()).toList()),
      'languages': jsonEncode(languages),
      'hobbies': hobbies.isNotEmpty ? hobbies : null,
      'theme_primary_color': '#${primaryColor.value.toRadixString(16).substring(2)}',
      'theme_accent_color': '#${accentColor.value.toRadixString(16).substring(2)}',
      'theme_bg_color': '#${bgColor.value.toRadixString(16).substring(2)}',
      'theme_text_color': '#${textColor.value.toRadixString(16).substring(2)}',
      'profile_visibility': profileVisibility,
    };

    try {
      setState(() => isLoading = true);
      if (exists) {
        await IdenticardService.updateIdenticard(token!, data);
      } else {
        await IdenticardService.addIdenticard(token!, data);
        exists = true;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showColorPicker(String field, Color initialColor, Function(Color) onColorChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pick a color for $field'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: onColorChanged,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _showMapEditorDialog(String title, Map<String, String> map, Function(Map<String, String>) onSave) {
    final Map<String, String> tempMap = Map.from(map);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              children: [
                ...tempMap.entries.map((entry) => Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: entry.key),
                        decoration: const InputDecoration(labelText: 'Key'),
                        onChanged: (value) {
                          final oldValue = entry.value;
                          tempMap.remove(entry.key);
                          tempMap[value] = oldValue;
                        },
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: entry.value),
                        decoration: const InputDecoration(labelText: 'Value'),
                        onChanged: (value) => tempMap[entry.key] = value,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setStateDialog(() => tempMap.remove(entry.key)),
                    ),
                  ],
                )),
                ElevatedButton(
                  onPressed: () => setStateDialog(() => tempMap[''] = ''),
                  child: const Text('Add New'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onSave(tempMap);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showListEditorDialog(String title, List<String> list, Function(List<String>) onSave) {
    final List<String> tempList = List.from(list);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              children: [
                // Use an indexed map to track position in the list
                ...tempList.asMap().entries.map((entry) {
                  int index = entry.key;
                  String item = entry.value;

                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: item),
                          decoration: const InputDecoration(labelText: 'Item'),
                          onChanged: (value) => tempList[index] = value,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => setStateDialog(() {
                          tempList.removeAt(index);
                        }),
                      ),
                    ],
                  );
                }).toList(),
                ElevatedButton(
                  onPressed: () => setStateDialog(() => tempList.add('')),
                  child: const Text('Add New'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              onSave(tempList);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  void _showWorkplaceEditorDialog() {
    final List<Workplace> tempList = List.from(previousWorkplaces);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Previous Workplaces'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              children: [
                ...tempList.map((wp) => Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: wp.company),
                        decoration: const InputDecoration(labelText: 'Company'),
                        onChanged: (value) => wp.company = value,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: wp.position),
                        decoration: const InputDecoration(labelText: 'Position'),
                        onChanged: (value) => wp.position = value,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: wp.duration),
                        decoration: const InputDecoration(labelText: 'Duration'),
                        onChanged: (value) => wp.duration = value,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setStateDialog(() => tempList.remove(wp)),
                    ),
                  ],
                )),
                ElevatedButton(
                  onPressed: () => setStateDialog(() => tempList.add(Workplace(company: '', position: '', duration: ''))),
                  child: const Text('Add New'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => previousWorkplaces = tempList);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEducationEditorDialog() {
    final List<Education> tempList = List.from(education);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Education'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              children: [
                ...tempList.map((ed) => Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: ed.institution),
                        decoration: const InputDecoration(labelText: 'Institution'),
                        onChanged: (value) => ed.institution = value,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: ed.degree),
                        decoration: const InputDecoration(labelText: 'Degree'),
                        onChanged: (value) => ed.degree = value,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: ed.year),
                        decoration: const InputDecoration(labelText: 'Year'),
                        onChanged: (value) => ed.year = value,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setStateDialog(() => tempList.remove(ed)),
                    ),
                  ],
                )),
                ElevatedButton(
                  onPressed: () => setStateDialog(() => tempList.add(Education(institution: '', degree: '', year: ''))),
                  child: const Text('Add New'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => education = tempList);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCertificationEditorDialog() {
    final List<Certification> tempList = List.from(certifications);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Certifications'),
        content: SingleChildScrollView(
          child: StatefulBuilder(
            builder: (context, setStateDialog) => Column(
              children: [
                ...tempList.map((cert) => Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: cert.name),
                        decoration: const InputDecoration(labelText: 'Name'),
                        onChanged: (value) => cert.name = value,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: cert.issuer),
                        decoration: const InputDecoration(labelText: 'Issuer'),
                        onChanged: (value) => cert.issuer = value,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: cert.year),
                        decoration: const InputDecoration(labelText: 'Year'),
                        onChanged: (value) => cert.year = value,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setStateDialog(() => tempList.remove(cert)),
                    ),
                  ],
                )),
                ElevatedButton(
                  onPressed: () => setStateDialog(() => tempList.add(Certification(name: '', issuer: '', year: ''))),
                  child: const Text('Add New'),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => certifications = tempList);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Identicard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.alternate_email),
                  ),
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: birthdayController,
                  decoration: const InputDecoration(
                    labelText: 'Birthday',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  readOnly: true,
                  onTap: _showDatePicker,
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: pronounsController,
                  decoration: const InputDecoration(
                    labelText: 'Pronouns',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: relationshipStatusController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship Status',
                    prefixIcon: Icon(Icons.favorite),
                  ),
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: websiteController,
                  decoration: const InputDecoration(
                    labelText: 'Website',
                    prefixIcon: Icon(Icons.language),
                  ),
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: currentWorkplaceController,
                  decoration: const InputDecoration(
                    labelText: 'Current Workplace',
                    prefixIcon: Icon(Icons.business),
                  ),
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: jobTitleController,
                  decoration: const InputDecoration(
                    labelText: 'Job Title',
                    prefixIcon: Icon(Icons.work),
                  ),
                ),
                const SizedBox(height: 16.0),

                TextField(
                  controller: portfolioLinkController,
                  decoration: const InputDecoration(
                    labelText: 'Portfolio Link',
                    prefixIcon: Icon(Icons.link),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Responsive grid layout for buttons
                LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonWidth = constraints.maxWidth > 600 ?
                    (constraints.maxWidth - 16) / 3 : // 3 buttons per row on larger screens
                    (constraints.maxWidth - 8) / 2;   // 2 buttons per row on smaller screens

                    return Wrap(
                      spacing: 8.0,
                      runSpacing: 12.0,
                      children: [
                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton.icon(
                            onPressed: () => _showMapEditorDialog('Messaging Apps', messagingApps, (map) => setState(() => messagingApps = map)),
                            icon: const Icon(Icons.message),
                            label: const Text('Messaging Apps'),
                          ),
                        ),

                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton.icon(
                            onPressed: () => _showMapEditorDialog('Social Handles', socialHandles, (map) => setState(() => socialHandles = map)),
                            icon: const Icon(Icons.public),
                            label: const Text('Social Handles'),
                          ),
                        ),

                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton.icon(
                            onPressed: _showWorkplaceEditorDialog,
                            icon: const Icon(Icons.business_center),
                            label: const Text('Previous Workplaces'),
                          ),
                        ),

                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton.icon(
                            onPressed: _showEducationEditorDialog,
                            icon: const Icon(Icons.school),
                            label: const Text('Education'),
                          ),
                        ),

                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton.icon(
                            onPressed: () => _showListEditorDialog('Skills', skills, (list) => setState(() => skills = list)),
                            icon: const Icon(Icons.psychology),
                            label: const Text('Skills'),
                          ),
                        ),

                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton.icon(
                            onPressed: _showCertificationEditorDialog,
                            icon: const Icon(Icons.card_membership),
                            label: const Text('Certifications'),
                          ),
                        ),

                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton.icon(
                            onPressed: () => _showMapEditorDialog('Languages', languages, (map) => setState(() => languages = map)),
                            icon: const Icon(Icons.translate),
                            label: const Text('Languages'),
                          ),
                        ),

                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton.icon(
                            onPressed: () => _showListEditorDialog('Hobbies', hobbies, (list) => setState(() => hobbies = list)),
                            icon: const Icon(Icons.interests),
                            label: const Text('Hobbies'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24.0),

                // Color pickers section
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: Text('Theme Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        ListTile(
                          leading: const Icon(Icons.color_lens),
                          title: const Text('Primary Color'),
                          trailing: CircleAvatar(backgroundColor: primaryColor),
                          onTap: () => _showColorPicker('Primary Color', primaryColor, (color) => setState(() => primaryColor = color)),
                        ),
                        const SizedBox(height: 8.0),

                        ListTile(
                          leading: const Icon(Icons.brush),
                          title: const Text('Accent Color'),
                          trailing: CircleAvatar(backgroundColor: accentColor),
                          onTap: () => _showColorPicker('Accent Color', accentColor, (color) => setState(() => accentColor = color)),
                        ),
                        const SizedBox(height: 8.0),

                        ListTile(
                          leading: const Icon(Icons.format_paint),
                          title: const Text('Background Color'),
                          trailing: CircleAvatar(backgroundColor: bgColor),
                          onTap: () => _showColorPicker('Background Color', bgColor, (color) => setState(() => bgColor = color)),
                        ),
                        const SizedBox(height: 8.0),

                        ListTile(
                          leading: const Icon(Icons.text_fields),
                          title: const Text('Text Color'),
                          trailing: CircleAvatar(backgroundColor: textColor),
                          onTap: () => _showColorPicker('Text Color', textColor, (color) => setState(() => textColor = color)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Profile visibility dropdown
                DropdownButtonFormField<String>(
                  value: profileVisibility,
                  items: ['public', 'private'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => profileVisibility = value!),
                  decoration: const InputDecoration(
                    labelText: 'Profile Visibility',
                    prefixIcon: Icon(Icons.visibility),
                  ),
                ),
                const SizedBox(height: 32.0),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _saveData,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Profile', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}