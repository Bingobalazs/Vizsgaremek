import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:blabber/screens/chat.dart';


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
    final response = await http.get(Uri.parse('https://kovacscsabi.moriczcloud.hu/api/friends/34')); //34 az a tj id-ja, majd ki kell cserélni az auth-ra

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
                          builder: (context) => Chat(),
                          settings: RouteSettings(arguments: {"id": user['user_id'], "name": user['name']}),
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
