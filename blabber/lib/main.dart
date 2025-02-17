import 'package:blabber/screens/friend_suggestions.dart';
import 'package:blabber/screens/user_profile_screen.dart';
import 'package:blabber/screens/auth_screen.dart';
import 'package:blabber/screens/styled_auth_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    title: 'Navigation Basics',
    home: FirstRoute(),
  ));
}

class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Route'),
      ),
      body: Center(
        child: new Column(
          children: [
            ElevatedButton(
            child: const Text('Add friends'),
            onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FriendSuggestionsScreen()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('My profile'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Log In/Register'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  LoginPage()),
                );
              },
            ),
              ElevatedButton(
              child: const Text('Log In/Register'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  AuthWidget()),
                );
              },
            ),
              ElevatedButton(
              child: const Text('Log In/Register'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  LoginPage()),
                );
              },
            ),
              ElevatedButton(
              child: const Text('Log In/Register'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  LoginPage()),
                );
              },
            ),

          ],
        ),
      ),
    );
  }
}


