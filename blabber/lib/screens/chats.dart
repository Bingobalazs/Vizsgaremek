//Nem tudom a user_profile_screen mit csinál, de azt nem mertem átírni

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'user_screen.dart'; // Importáljuk a külön fájlban lévő NewScreen-t

// Chats képernyő, ahol a barátkérelmek és a felhasználók adatait jelenítjük meg.
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
      appBar: AppBar(title: Text('Felhasználók')),
      body: friendRequests.isEmpty && users.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              // A listában egy fejléc, a barátkérelmek, egy elválasztó és utána a jóváhagyott felhasználók szerepelnek.
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
                // Barátkérelmek listaelemei: minden elem mellett két gomb található:
                // - "Elfogadás" a kérelem jóváhagyásához,
                // - "Új gomb" a NewScreen megnyitásához az adott barátkérés id-jával.
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
                // Elválasztó a barátkérelmek és a jóváhagyott felhasználók között.
                else if (index == friendRequests.length + 1) {
                  return Divider(
                    color: Colors.grey,
                    thickness: 1,
                    height: 20,
                  );
                }
                // Jóváhagyott felhasználók listaelemei: mindkét műveletre (chat indítás és az új képernyő megnyitása) két gomb található.
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
                          child: Text('Dumcsi mumcsi'),
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

// Példa Chat képernyő, mely a csevegés funkciót mutatja be.
class Chat extends StatelessWidget {
  final String userId;
  final String friendId;
  final String friendName;

  const Chat({
    Key? key,
    required this.userId,
    required this.friendId,
    required this.friendName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat: $friendName'),
      ),
      body: Center(
        child: Text('Chat screen between user $userId and friend $friendId.'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Chats(),
  ));
}
