import 'package:flutter/material.dart';
import 'identicard_edit_screen.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static String routeName = 'Profile08';
  static String routePath = '/profile08';

  @override
  State<ProfilePage> createState() => ProfilePageState();
}
// TODO: implement user profile
// TODO:  Edit colors to global theme colors
// TODO: replace HomeScreen() to actual screens when készen vannak

// fetch user info
/*



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


*/


class ProfilePageState extends State<ProfilePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Colors.grey[200], // Replace with your desired background color
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
                      color: Colors.blueAccent, // Replace with your desired color
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8dXNlcnxlbnwwfHwwfHw%3D&auto=format&fit=crop&w=900&q=60',
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
                  'David Jerome',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Roboto Mono',
                    fontSize: 24,
                    color: Colors.blue, // Replace with your desired color
                  ),
                ),
              ),
              Text(
                'David.j@gmail.com',
                style: TextStyle(
                  fontFamily: 'Roboto Mono',
                  fontSize: 16,
                  color: Colors.grey[600], // Replace with your desired color
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 50),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent, // Replace with your desired color
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
                              _buildActionButton(Icons.edit_note_rounded, 'edit', EditIdenticardScreen()),
                              _buildActionButton(Icons.qr_code, 'share', HomePage()),
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
                    _buildActionButton(Icons.people_sharp, 'friends', HomePage()),
                    _buildActionButton(Icons.grid_on_sharp, 'my posts', HomePage()),
                    _buildActionButton(Icons.settings_sharp, 'settings', HomePage()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Widget targetScreen) {
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
                  color: Colors.grey[300], // Replace with your desired color
                  shape: BoxShape.rectangle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  icon,
                  color: Colors.blueAccent, // Replace with your desired color
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