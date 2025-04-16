import 'dart:convert';
import 'dart:typed_data'; // Needed for web image bytes
import 'package:blabber/screens/setting_screen.dart';
import 'package:http_parser/http_parser.dart'; // For MediaType

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'identicard_edit_screen.dart';
import '../main.dart';
import 'identishare_screen.dart';
import 'own_posts_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blabber/screens/friends_list_screen.dart';



class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static String routeName = 'profile';
  static String routePath = '/profile';



  @override
  State<ProfilePage> createState() => ProfilePageState();

}


class ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? userData;
  static const accentColor = Color.fromRGBO(255, 32, 78, 1);
  static const baseColor = Color.fromRGBO(0, 34, 77, 1);
  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }
  Future<void> fetchUserProfile() async {
    try {
      // Get token from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          error = 'No authentication token found';
          isLoading = false;
        });
        return;
      }

      // Make API request
      final response = await http.get(
        Uri.parse('https://kovacscsabi.moriczcloud.hu/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load profile: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error: $e';
        isLoading = false;
      });
    }
  }
  Future<void> _pickAndUploadImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      final String apiUrl = 'https://kovacscsabi.moriczcloud.hu/api/pfp/set';
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

      // For web support, use bytes instead of file path
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'profile_picture',
          bytes,
          filename: image.name,
          contentType: MediaType('image', image.path.split('.').last),
        ),
      );

      // Add any additional fields if required
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        // Handle successful upload
        final responseData = await response.stream.bytesToString();
        // Parse responseData and update userData if needed
        setState(() {
          // Update UI with new image
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to upload image')),
        );
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: baseColor, // Replace with your desired background color
        body: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Stack(
                  alignment: Alignment.bottomRight, // Position button at bottom-right
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: baseColor,
                        ),
                      ),
                      child: isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Padding(
                              padding: const EdgeInsets.all(5),
                              child: Image.network(
                                "https://kovacscsabi.moriczcloud.hu/${userData?['pfp_url']}" ??
                                    'https://pixabay.com/vectors/blank-profile-picture-mystery-man-973460/',
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.network(
                                  'https://pixabay.com/vectors/blank-profile-picture-mystery-man-973460/',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                    ),

                    // Add the edit button
                    GestureDetector(
                      onTap: () async {
                        await _pickAndUploadImage();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: baseColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        userData?['name'] ?? 'Jelentkezz be!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Roboto Mono',
                          fontSize: 24,
                          color: accentColor,
                        ),
                      ),
              ),
              isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      userData?['email'] ?? 'Jelentkezz be!',
                      style: TextStyle(
                        fontFamily: 'Roboto Mono',
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                ),


              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: accentColor,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            'IDenticard',
                            style: TextStyle(
                              fontFamily: 'Roboto Mono',
                              fontSize: 24,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildActionButton(icon: Icons.edit_note_rounded,
                                 label:  'szerkesztés',
                                  targetScreen:
                                  IdenticardScreen()
                              ),
                              _buildActionButton(
                                  icon: Icons.qr_code,
                                  label:  'megosztás',
                                  targetScreen:  IdentiCardScreen()
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildActionButton(icon: Icons.people_sharp,
                        label: 'barátok',
                        targetScreen:  FriendsList(),
                        backgroundColor: accentColor,
                        iconColor: baseColor),
                    _buildActionButton(icon: Icons.grid_on_sharp,
                        label: 'bejegyzéseim',
                        targetScreen:  OwnPostsScreen(),
                        backgroundColor: accentColor,
                        iconColor: baseColor),
                    _buildActionButton(icon: Icons.settings_sharp,
                        label: 'beállítások',
                        targetScreen:  SettingsPage(),
                        backgroundColor: accentColor,
                        iconColor: baseColor),
                  ],
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Widget targetScreen,
    Color? iconColor,
    Color? backgroundColor
  }) {
    return Expanded(
      child: InkWell(
         onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => targetScreen),
        );
      },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: backgroundColor ?? baseColor,
                  shape: BoxShape.rectangle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: iconColor ?? accentColor,
                  size: 24,
                ),
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Roboto Mono',
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

