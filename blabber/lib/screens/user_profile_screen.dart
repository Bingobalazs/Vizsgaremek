import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'identicard_edit_screen.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static String routeName = 'profile';
  static String routePath = '/profile';
  static const accentColor = Color.fromRGBO(255, 32, 78, 1);
  static const baseColor = Color.fromRGBO(0, 34, 77, 1);

  @override
  State<ProfilePage> createState() => ProfilePageState();

}
// TODO: implement user profile
// TODO:  Edit colors to global theme colors
// TODO: replace HomeScreen() to actual screens when készen vannak

// fetch user info









class ProfilePageState extends State<ProfilePage> {
  bool isLoading = true;
  String? error;
  Map<String, dynamic>? userData;

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
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: baseColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.network(
                      userData?['image_url'] ?? 'https://pixabay.com/vectors/blank-profile-picture-mystery-man-973460/',
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  userData?['name'] ?? 'Please log in',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto Mono',
                    fontSize: 24,
                    color: accentColor,
                  ),
                ),
              ),
              Text(
                userData?['email']?? 'Please log in',
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
                                 label:  'edit',
                                  targetScreen:
                                  EditIdenticardScreen()
                              ),
                              _buildActionButton(
                                  icon: Icons.qr_code,
                                  label:  'share',
                                  targetScreen:  HomePage()
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
                        label: 'friends',
                        targetScreen:  HomePage(),
                        backgroundColor: accentColor,
                        iconColor: baseColor),
                    _buildActionButton(icon: Icons.grid_on_sharp,
                        label: 'my posts',
                        targetScreen:  HomePage(),
                        backgroundColor: accentColor,
                        iconColor: baseColor),
                    _buildActionButton(icon: Icons.settings_sharp,
                        label: 'settings',
                        targetScreen:  HomePage(),
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