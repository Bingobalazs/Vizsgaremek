import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_screen.dart';
import 'chat.dart'; // Importáljuk a chat képernyőt

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
      body: friendRequests.isEmpty && users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              // A listában szerepel egy fejléc, a barátkérelmek, majd egy elválasztó, végül a jóváhagyott felhasználók
              itemCount: friendRequests.length + users.length + 2,
              itemBuilder: (context, index) {
                // Fejléc a barátkérelmekhez.
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Barátkérelmek:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
                // Barátkérelmek listaelemei.
                else if (index <= friendRequests.length) {
                  final request = friendRequests[index - 1];
                  return ListTile(
                    title: Text(
                      request['name'],
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          child: Text('Elfogadás'),
                          onPressed: () async {
                            final prefs = await SharedPreferences.getInstance();
                            final token = prefs.getString('auth_token');

                            final requestId = request['id'];
                            final response = await http.post(
                              Uri.parse(
                                  'https://kovacscsabi.moriczcloud.hu/api/accept/$requestId'),
                              headers: {'Authorization': 'Bearer $token'},
                            );

                            if (response.statusCode == 200) {
                              await fetchUsers();
                              await fetchFriendRequests();
                            }
                          },
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          child: Text('Új gomb'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserScreen(
                                  userId: request['id'].toString(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
                // Elválasztó
                else if (index == friendRequests.length + 1) {
                  return Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 20,
                  );
                }
                // Jóváhagyott felhasználók listaelemei.
                else {
                  final user = users[index - friendRequests.length - 2];
                  return ListTile(
                    title: Text(
                      user['name'],
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          child: Text('Dumcsi'),
                          // A Dumcsi gomb most a chat.dart-ban definiált Chat widgetet hívja meg.
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Chat(
                                  userId:
                                      '34', // Példa: az aktuális felhasználó ID-je
                                  friendId: user['user_id'].toString(),
                                  friendName: user['name'],
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(width: 8),
                        ElevatedButton(
                          child: Text('Részletek'),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserScreen(
                                  userId: user['user_id'].toString(),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
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
