import 'package:blabber/screens/chats.dart';
import 'package:blabber/screens/friend_suggestions.dart';
import 'package:blabber/screens/identicard_edit_screen.dart';
import 'package:blabber/screens/user_profile_screen.dart';
import 'package:blabber/screens/auth_screen.dart';
import 'package:blabber/screens/add_post_screen.dart';
import 'package:blabber/screens/loading_screen.dart';
import 'package:blabber/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:blabber/screens/search_screen.dart';
import 'package:blabber/screens/feed_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(MyApp());
}
Future<bool> isLoggedIn() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  return token != null;
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        cardTheme: CardTheme(
          color: Color.fromRGBO(0, 34, 77, 1),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),


        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white), // Beviteli szöveg színe
          bodyMedium: TextStyle(color: Colors.white), // Szöveg színe
          bodySmall: TextStyle(color: Colors.white), // Szöveg színe
          titleLarge: TextStyle(color: Colors.white), // Fejlec szöveg színe
          titleMedium: TextStyle(color: Colors.white), // Fejlec szöveg színe
          titleSmall: TextStyle(color: Colors.white), // Fejlec szöveg színe
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color.fromRGBO(255, 32, 78, 1), // Background color
            foregroundColor: Colors.white, // Text color
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(0), // Rounded corners
            ),
            elevation: 3, // Shadow effect
          ),
        ),
        primaryColor: Color.fromRGBO(0, 34, 77, 1),

        scaffoldBackgroundColor:
            Color.fromRGBO(0, 34, 77, 1), // Change this for app background
        appBarTheme: AppBarTheme(
            backgroundColor: Color.fromRGBO(255, 32, 78, 1),
            foregroundColor: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.white), // Címke (label) színe
          hintStyle: TextStyle(
              color: Colors.white70), // Placeholder szöveg (hint) színe
          errorStyle: TextStyle(color: Colors.red), // Hibaüzenet színe
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(255, 32, 78, 1), width: 2.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Color.fromRGBO(255, 32, 78, 1), width: 0.5),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red, width: 2.0),
          ),
        ),
      ),
      home: FutureBuilder<bool>(
        future: isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('Error checking auth status')));
          }

          final isLoggedIn = snapshot.data ?? false;
          return isLoggedIn ? HomePage() : LoginPage();
        },
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
    FeedScreen(),
    SearchScreen(),
    AddPostScreen(),
    Chats(),
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
          builder: (context) => AddPostScreen(),
        ),
      );
    }
  }

  final selectedColor = Color.fromRGBO(255, 32, 78, 1);
  final baseColor = Color.fromRGBO(0, 34, 77, 1);

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
