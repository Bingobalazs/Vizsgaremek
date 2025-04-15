import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blabber/models/Post.dart';
import 'package:blabber/widgets/post_widget.dart'; // Ellenőrizd a helyes import útvonalat!
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserScreen extends StatefulWidget {
  final String userId;

  const UserScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _OtherUserScreenState createState() => _OtherUserScreenState();
}

class _OtherUserScreenState extends State<UserScreen> {
  bool _isMarked = false;

  // Lekéri a felhasználó adatait a megadott URL-ről.
  Future<Map<String, dynamic>> fetchUserData() async {
    final url =
        'https://kovacscsabi.moriczcloud.hu/api/getUser/${widget.userId}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Nem sikerült betölteni az adatokat.');
    }
  }

  // Jelölés végrehajtása: az API POST kérésével
  Future<void> markUser() async {
    // Azonnal beállítjuk az állapotot, így a gomb eltűnik a UI-ból
    setState(() {
      _isMarked = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final url =
        'https://kovacscsabi.moriczcloud.hu/api/jeloles/${widget.userId}';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sikeres jelölés!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Jelölés sikertelen. Hiba kód: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hiba: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Felhasználó Profil'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserData(),
        builder: (context, snapshot) {
          // Amíg a válasz meg nem érkezik, mutatunk egy körbeforgó indikátort.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Hiba esetén megjelenítjük a hibát.
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
                  // Felhasználói adatok megjelenítése
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            user['name'],
                            style: const TextStyle(fontSize: 30),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user['email'],
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                      Image(
                        width: 100,
                        height: 100,
                        image: NetworkImage(
                          'https://kovacscsabi.moriczcloud.hu/${user['pfp_url']}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Jelölés gomb: csak akkor jelenik meg, ha még nincs jelölve
                  if (!_isMarked)
                    Center(
                      child: ElevatedButton(
                        onPressed: markUser,
                        child: const Text("Jelölés"),
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Posztok:',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  // A posztok megjelenítése PostWidget segítségével.
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: postsData.length,
                    itemBuilder: (context, index) {
                      final postJson = postsData[index] as Map<String, dynamic>;
                      // Létrehozunk egy Post objektumot, alapértelmezett értékekkel a hiányzó adatokhoz.
                      final post = Post(
                        id: postJson['id'],
                        content: postJson['content'] ?? '',
                        mediaUrl: postJson['media_url'],
                        createdAt: postJson['created_at'],
                        userName: user['name'],
                        isLiked: false,
                        likeCount: 0,
                        isUnseen: false,
                      );

                      return PostWidget(post: post);
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
