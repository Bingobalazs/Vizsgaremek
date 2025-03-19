import 'dart:convert';
import 'package:blabber/main.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blabber/screens/chat.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Chats extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<Chats> {
  
  List users = []; // Ebben tároljuk a felhasználókat

  @override
  void initState() {
    super.initState();
    fetchUsers(); // API hívás betöltéskor
  }

  Future<void> fetchUsers() async {

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(Uri.parse(
        'https://kovacscsabi.moriczcloud.hu/api/friends'), headers: {'Authorization': 'Bearer $token'}); /* //34 az a tj id-ja, majd ki kell cserélni az auth-ra*/

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body); // JSON konvertálása List-é
      });
    } else {
      throw Exception('Nem sikerült az adatok lekérése');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Felhasználók')),
      body: users.isEmpty
          ? Center(child: CircularProgressIndicator()) // Töltőképernyő
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['name']), // Név kiírása
                  trailing: ElevatedButton(
                    child: const Text('Dumcsi mumcsi'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Chat(
                              userId: '34',
                              friendId: user['user_id'].toString(),
                              friendName: user['name']),
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
    home: Chats(),
  ));
}
