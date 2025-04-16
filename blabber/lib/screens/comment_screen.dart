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
  List<Comment> _comments = [];
  bool _isLoading = true;
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Lekéri az auth token-t a SharedPreferences-ből
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No token found');
    return token;
  }

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      String token = await _getToken();
      final url =
          'https://kovacscsabi.moriczcloud.hu/api/getcomments/${widget.postId}';
      final response = await http.get(Uri.parse(url), headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        setState(() {
          _comments = jsonData.map((json) => Comment.fromJson(json)).toList();
          _comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          _isLoading = false;
        });
        _scrollToBottom();
      } else {
        setState(() {
          _isLoading = false;
        });
        throw Exception('Error fetching comments: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      rethrow;
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
            widget.postId, // Cseréld le a bejelentkezett felhasználó tényleges ID-jára!
      },
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      try {
        final Map<String, dynamic> resJson = json.decode(response.body);
        if (resJson.containsKey('comment')) {
          final data = resJson['comment'];
          final newComment = Comment.fromJson(data);
          setState(() {
            _comments.add(newComment);
            _comments.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          });
        } else {
          await _fetchComments();
        }
      } catch (e) {
        await _fetchComments();
      }
      _scrollToBottom();
    } else {
      throw Exception('Error adding comment: ${response.statusCode}');
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
        "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    // A maximum szélességet érdemes beállítani, hogy nagyon hosszú szöveg esetén se nyúljon túl.
    final maxCardWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hozzászólások"),
        centerTitle: true,
        elevation: 4,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _comments.isEmpty
                    ? const Center(child: Text("Nincsenek hozzászólások."))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _comments.length,
                        itemBuilder: (context, index) {
                          final comment = _comments[index];
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                               
                                maxWidth: maxCardWidth,
                              ),
                              child: IntrinsicWidth(
                                child: Card(
                                  color: Colors.white,
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6.0),
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          comment.userName,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          comment.comment,
                                          style: const TextStyle(
                                              color: Colors.black87),
                                        ),
                                        const SizedBox(height: 6),
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Text(
                                            _formatDate(comment.createdAt),
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black87),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    style: const TextStyle(color: Colors.black),
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
                                content: Text("Hiba a hozzászólás küldésekor")),
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
    _scrollController.dispose();
    super.dispose();
  }
}
