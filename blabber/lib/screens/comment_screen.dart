import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Comment {
  final int id;
  final int postId;
  final String comment;
  final int userId;
  final String userName;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.comment,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'] ?? json['post'],
      comment: json['comment'],
      userId: json['user_id'],
      userName: json['user'] != null && json['user']['name'] != null
          ? json['user']['name']
          : "User ${json['user_id']}",
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class CommentScreen extends StatefulWidget {
  final int postId;

  const CommentScreen({Key? key, required this.postId}) : super(key: key);

  @override
  _CommentScreenState createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No token found');
    return token;
  }

  late Future<List<Comment>> _futureComments;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureComments = _fetchComments();
  }

  Future<List<Comment>> _fetchComments() async {
    String token = await _getToken();
    final url =
        'https://kovacscsabi.moriczcloud.hu/api/getcomments/${widget.postId}';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      return jsonData.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching comments: ${response.statusCode}');
    }
  }

  Future<void> _addComment(String commentText) async {
    String token = await _getToken();
    final url = 'https://kovacscsabi.moriczcloud.hu/api/addcomment';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
      body: {
        "post_id": widget.postId.toString(),
        "comment": commentText,
        "user_id":
            "34", // Ezt a bejelentkezett felhasználó tényleges azonosítójára kell cserélni
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        _futureComments = _fetchComments();
      });
    } else {
      throw Exception('Error adding comment: ${response.statusCode}');
    }
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hozzászólások"),
        centerTitle: true,
        elevation: 4,
      ),
      // Alapértelmezett, fehér háttér
      body: Column(
        children: [
          // Hozzászólások listája
          Expanded(
            child: FutureBuilder<List<Comment>>(
              future: _futureComments,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Hiba: ${snapshot.error}"));
                }
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(child: Text("Nincsenek hozzászólások."));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Card(
                      color: Colors.white, // Fehér card háttér
                      margin: const EdgeInsets.symmetric(vertical: 6.0),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12.0),
                        // Profilkép nélkül
                        title: Text(
                          comment.userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            comment.comment,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ),
                        trailing: Text(
                          _formatDate(comment.createdAt),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          // Új hozzászólás beviteli rész
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(
                        color: Colors.black), // Input mező szövege fekete
                    decoration: InputDecoration(
                      hintText: 'Írd ide a hozzászólást...',
                      hintStyle: const TextStyle(color: Colors.black45),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Material(
                  color: Theme.of(context).primaryColor,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () async {
                      final text = _commentController.text;
                      if (text.trim().isNotEmpty) {
                        try {
                          await _addComment(text.trim());
                          _commentController.clear();
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Hiba a hozzászólás küldésekor"),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
