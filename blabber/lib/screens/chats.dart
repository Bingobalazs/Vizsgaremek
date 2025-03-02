import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chats extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<Chats> {
  List friends = [];

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    final response = await http.get(Uri.parse(
        'https://kovacscsabi.moriczcloud.hu/friends/34')); //Itt az id legyen a bejelentkezett felhasználó (34 az a tj id)

    if (response.statusCode == 200) {
      setState(() {
        friends = json.decode(response.body);
      });
    } else {
      throw Exception('Hiba az adatok lekérésekor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Barátok listája')),
      body: friends.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                final friend = friends[index];
                return ListTile(
                  title: Text('Felhasználó ID: ${friend['user_id']}'),
                  subtitle: Text('Barát ID: ${friend['id']}'),
                );
              },
            ),
    );
  }
}
