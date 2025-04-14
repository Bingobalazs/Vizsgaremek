//Nem tudom a user_profile_screen mit csinál, de azt nem mertem átírni

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class UserScreen extends StatelessWidget {
  final String userId;

  const UserScreen({Key? key, required this.userId}) : super(key: key);

  // Függvény, ami lekéri a JSON adatokat a megadott URL-ről.
  Future<Map<String, dynamic>> fetchUserData() async {
    // Az URL-ben dinamikusan behelyettesítjük a userId-t.
    final url = 'https://kovacscsabi.moriczcloud.hu/api/getUser/$userId';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // A JSON szöveget egy Map-é alakítjuk.
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Nem sikerült betölteni az adatokat.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          // Amíg nem érkezett a válasz, egy körbeforgó indikátort mutatunk.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Hiba esetén megjelenítjük az üzenetet.
          if (snapshot.hasError) {
            return Center(child: Text('Hiba: ${snapshot.error}'));
          }

          // Sikeres lekérés esetén kibontjuk a kapott JSON-t.
          final data = snapshot.data!;
          final user = data['user'] as Map<String, dynamic>;
          final posts = data['posts'] as Map<String, dynamic>;
          final List<dynamic> postsData = posts['data'];

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    '${user['name']}',
                    style: TextStyle(fontSize: 30),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${user['email']}',
                    style: TextStyle(fontSize: 15),
                  ),
                  SizedBox(height: 16),
                  Divider(),
                  SizedBox(height: 16),
                  Text(
                    'Posztok:',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  // A posztok listáját ListView.builder-rel jelenítjük meg,
                  // melynek scrollozását a SingleChildScrollView illeti át.
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: postsData.length,
                    itemBuilder: (context, index) {
                      final post = postsData[index] as Map<String, dynamic>;

                      DateTime createdAt = DateTime.parse(post['created_at']);
                      String formattedDate =
                          DateFormat('yyyy MM dd - HH:mm').format(createdAt);

                      return ListTile(
                        title: Text(
                          post['content'] ?? '',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        subtitle: Text('${formattedDate}'),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
