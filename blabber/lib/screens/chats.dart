import 'dart:convert';
import 'package:blabber/main.dart';
import 'package:blabber/screens/identicard_edit_screen.dart';
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
  List users = [];
  List requests = [];

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchRequests();
  }

  Future<void> fetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
        Uri.parse('https://kovacscsabi.moriczcloud.hu/api/friends'),
        headers: {
          'Authorization': 'Bearer $token'
        }); /* //34 az a tj id-ja, majd ki kell cserélni az auth-ra*/

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body); // JSON konvertálása List-é
      });
    } else {
      throw Exception('Nem sikerült az adatok lekérése');
    }
  }

  Future<void> fetchRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final response = await http.get(
        Uri.parse('https://kovacscsabi.moriczcloud.hu/api/friend_req'),
        headers: {'Authorization': 'Bearer $token'});

    if (response.statusCode == 200) {
      setState(() {
        requests = json.decode(response.body); // JSON konvertálása List-é
      });
    } else {
      throw Exception('Nem sikerült az adatok lekérése');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Felhasználók')),
      body: users.isEmpty && requests.isEmpty
          ? Center(child: CircularProgressIndicator()) // Töltőképernyő
          : ListView.builder(
              itemCount: requests.length + users.length + 2,
              itemBuilder: (context, index) {
<<<<<<< Updated upstream
                if (index == 0) {
                  // Cím a requests szegmenshez
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Ezek az mf-ek akarnak téged 🔥🔥🔥',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                } else if (index <= requests.length) {
                  final request = requests[index - 1];
                  return ListTile(
                    title: Text('${request['name']}',
                        style: TextStyle(color: Colors.white)),
                    trailing: ElevatedButton(
                      child: const Text('Elfogadás'),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final token = prefs.getString('auth_token');

                        final requestId = request['id'];
                        final response = await http.post(
                            Uri.parse(
                                'https://kovacscsabi.moriczcloud.hu/api/accept/$requestId'),
                            headers: {'Authorization': 'Bearer $token'});

                        if (response.statusCode == 200) {
                          await fetchUsers();
                          await fetchRequests();
                        }
                      },
                    ),
                  );
                } else if (index == requests.length + 1) {
                  // Divider a requests és a users között
                  return Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 20,
                  );
                } else {
                  final user = users[index - requests.length - 2];
                  return ListTile(
                    title: Text(user['name'],
                        style: TextStyle(color: Colors.white)),
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
                }
=======
                final user = users[index];
                return ListTile(
                  title: Text(user['name'], style: TextStyle(color: Colors.white)), // Név kiírása
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
>>>>>>> Stashed changes
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
