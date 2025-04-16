import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_screen.dart';
import 'chat.dart'; // Importáljuk a chat képernyőt
import 'other_user_screen.dart';

class Chats extends StatefulWidget {
  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  List users = [];
  List friendRequests = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchFriendRequests();
  }

  Future<void> fetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('https://kovacscsabi.moriczcloud.hu/api/friends'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    } else {
      throw Exception('Nem sikerült az adatok lekérése a felhasználókról.');
    }
  }

  Future<void> fetchFriendRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
      Uri.parse('https://kovacscsabi.moriczcloud.hu/api/friend_req'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      setState(() {
        friendRequests = json.decode(response.body);
      });
    } else {
      throw Exception('Nem sikerült az adatok lekérése a barátkérelmekről.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Felhasználók'),
      ),
      body: users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        // Csak a felhasználók listája
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(
              user['name'],
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              // A felhasználónévre kattintva részletek megjelenítése
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OtherUserScreen(
                    userId: user['user_id'].toString(),
                  ),
                ),
              );
            },
            trailing: ElevatedButton(
              child: Text('Dumcsi'),
              // A Dumcsi gomb a chat.dart-ban definiált Chat widgetet hívja meg.
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Chat(
                      userId: '34',
                      friendId: user['user_id'].toString(),
                      friendName: user['name'],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Chats App',
    theme: ThemeData.dark(),
    home: Chats(),
  ));
}
