import 'package:blabber/screens/friend_suggestions.dart';
import 'package:blabber/screens/user_profile_screen.dart';
import 'package:blabber/screens/auth_screen.dart';
import 'package:blabber/screens/identicard_form.dart';
import 'package:blabber/screens/add_post_screen.dart';
import 'package:blabber/screens/loading_screen.dart';
import 'package:blabber/screens/chat.dart';
import 'package:flutter/material.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(255, 32, 78, 1), // Background color
            foregroundColor: Color.fromRGBO(255, 255, 255, 1), // Text color
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0), // Rounded corners
            ),
            elevation: 3, // Shadow effect
          ),
        ),

        primaryColor:  Color.fromRGBO(0, 34, 77, 1),
        scaffoldBackgroundColor: Color.fromRGBO(0, 34, 77, 1), // Change this for app background
        appBarTheme: AppBarTheme(
          backgroundColor:  Color.fromRGBO(255, 32, 78, 1),
          foregroundColor: Colors.white
        )


        
      ),
      home: const LoadingScreen(),
    );
  }
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
                  MaterialPageRoute(
                      builder: (context) => const FriendSuggestionsScreen()),
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
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('my Identicard'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IdCardForm()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Log In/Register'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            ElevatedButton(
              child: const Text('Log In/Register'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
            ElevatedButton(
              child: Text('Chat'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Chat()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages to navigate to
  final List<Widget> _pages = [
     LoginPage(),
    const IdCardForm(),
    const AddPostScreen(),
    const FriendSuggestionsScreen(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index != 2) {
      // If not the add post button
      setState(() {
        _selectedIndex = index;
      });
    } else {
      // Navigate to add post screen with a different animation
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const AddPostScreen(),
        ),
      );
    }
  }
  final selectedColor = Color.fromRGBO(255, 32, 78, 1);
  final baseColor =  Color.fromRGBO(0, 34, 77, 1);
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
        color: baseColor,
        
        child: Container(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.home,
                  color: _selectedIndex == 0 ? selectedColor : Colors.white,
                ),
                onPressed: () => _onItemTapped(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: _selectedIndex == 1 ? selectedColor : Colors.white,
                ),
                onPressed: () => _onItemTapped(1),
              ),
              const SizedBox(width: 40.0), // Space for the FAB
              IconButton(
                icon: Icon(
                  Icons.message,
                  color: _selectedIndex == 3 ? selectedColor : Colors.white,
                ),
                onPressed: () => _onItemTapped(3),
              ),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: _selectedIndex == 4 ? selectedColor : Colors.white,
                ),
                onPressed: () => _onItemTapped(4),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(2),
        backgroundColor: selectedColor,
        elevation: 8.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  
    
  }

}

