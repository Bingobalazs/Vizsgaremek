import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// A Post modell, amelyet a API visszaad
class Post {
  final int id;
  final String content;
  final String createdAt;

  Post({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      createdAt: json['createdAt'] ?? 'ismeretlen időpont',
    );
  }
}
Future<String> _getToken() async {
  
final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) throw Exception('No token found');
      return token;
}

     

class OwnPostsScreen extends StatefulWidget {
  const OwnPostsScreen({Key? key}) : super(key: key);

  @override
  State<OwnPostsScreen> createState() => _OwnPostsScreenState();
}

class _OwnPostsScreenState extends State<OwnPostsScreen> {
  late Future<List<Post>> _postsFuture;

  // Állítsd be a saját API URL-edet itt!
  final String baseUrl = 'https://kovacscsabi.moriczcloud.hu/api/';
   

  @override
  void initState() {
    super.initState();
    _postsFuture = fetchPosts();
  }


  // Lekéri a posztokat az own/posts végpontról
  Future<List<Post>> fetchPosts() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('${baseUrl}own/posts'),
       headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Nem sikerült a posztok betöltése');
    }
  }

  // Törli a posztot a post/{postid} végponton keresztül
  Future<void> deletePost(int postId) async {
    final response = await http.delete(Uri.parse('${baseUrl}post/$postId'));
    if (response.statusCode == 200) {
      setState(() {
        _postsFuture = fetchPosts();
      });
    } else {
      throw Exception('Nem sikerült a poszt törlése');
    }
  }

  // Módosítja a posztot a post/{postid} végponton keresztül
  Future<void> updatePost(int postId, String newContent) async {
    final response = await http.put(
      Uri.parse('${baseUrl}post/$postId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'content': newContent}),
    );
    if (response.statusCode == 200) {
      setState(() {
        _postsFuture = fetchPosts();
      });
    } else {
      throw Exception('Nem sikerült a poszt módosítása');
    }
  }

  // Egy egyszerű dialógus, ahol módosítható a poszt tartalma
  void _showUpdateDialog(Post post) {
    final TextEditingController controller =
        TextEditingController(text: post.content);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Poszt módosítása'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'Új tartalom'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Mégse'),
          ),
          TextButton(
            onPressed: () {
              updatePost(post.id, controller.text);
              Navigator.pop(context);
            },
            child: Text('Mentés'),
          ),
        ],
      ),
    );
  }

  // Egy poszt widgetjének megjelenítése
  Widget _buildPostItem(Post post) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(color: Colors.blueAccent),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 20,
            color: Colors.blueAccent,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Text(
                    'ÉN',
                    style: TextStyle(
                      fontFamily: 'Roboto Mono',
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    post.createdAt,
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              post.content,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Ubuntu',
                color: Colors.blueAccent,
                fontSize: 20,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hozzászólás gomb (jelenleg csak nyomtat egy üzenetet)
              ElevatedButton.icon(
                onPressed: () {
                  print('Hozzászólás gomb megnyomva');
                },
                icon: Icon(Icons.comment_sharp, size: 15),
                label: Text('Szólj hozzá...'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.blueAccent),
                ),
              ),
              Row(
                children: [
                  // Módosítás gomb
                  ElevatedButton.icon(
                    onPressed: () => _showUpdateDialog(post),
                    icon: Icon(Icons.edit_sharp, size: 15),
                    label: Text('MÓDOSÍTÁS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  // Törlés gomb
                  ElevatedButton.icon(
                    onPressed: () => deletePost(post.id),
                    icon: Icon(Icons.delete_sharp, size: 15),
                    label: Text('TÖRLÉS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _refreshPosts() async {
    setState(() {
      _postsFuture = fetchPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posztok'),
      ),
      body: FutureBuilder<List<Post>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hiba: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Nincsenek posztok'));
          } else {
            final posts = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshPosts,
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return _buildPostItem(posts[index]);
                },
              ),
            );
          }
        },
      ),
    );
  }
}
