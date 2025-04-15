import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Post.dart';

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
  final List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _errorMessage;

  // Állítsd be a saját API URL-edet itt!
  final String baseUrl = 'https://kovacscsabi.moriczcloud.hu/api/';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPosts();

    // Add scroll listener to detect when user reaches the bottom
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll listener to check if user has reached the bottom
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMorePosts();
      }
    }
  }

  // Lekéri a posztokat az own/posts végpontról
  Future<void> _loadPosts() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${baseUrl}own/posts?page=1'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        List jsonResponse = body['posts'];
        _hasMore = body['has_more'] ?? false;

        setState(() {
          _posts.clear();
          _posts.addAll(jsonResponse.map((post) => Post.fromJson(post)).toList());
          _currentPage = 1;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Nem sikerült a posztok betöltése (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Hiba: $e';
        _isLoading = false;
      });
    }
  }

  // Loads more posts for pagination
  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('${baseUrl}own/posts?page=$nextPage'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        List jsonResponse = body['posts'];
        _hasMore = body['has_more'] ?? false;

        setState(() {
          _posts.addAll(jsonResponse.map((post) => Post.fromJson(post)).toList());
          _currentPage = nextPage;
          _isLoading = false;
        });
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = 'Nem sikerült további posztok betöltése (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Hiba: $e';
        _isLoading = false;
      });
    }
  }

  // Törli a posztot a post/{postid} végponton keresztül
  Future<void> deletePost(int postId) async {
    final token = await _getToken();

    final response = await http.delete(
        Uri.parse('${baseUrl}posts/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }
    );

    if (response.statusCode == 200) {
      setState(() {
        _posts.removeWhere((post) => post.id == postId);
      });
    } else {
      throw Exception('Nem sikerült a poszt törlése');
    }
  }

  // Módosítja a posztot a post/{postid} végponton keresztül
  Future<void> updatePost(int postId, String newContent) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('${baseUrl}posts/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': newContent}),
    );

    if (response.statusCode == 200) {
      final updatedPost = json.decode(response.body)['post'];

      setState(() {
        final index = _posts.indexWhere((post) => post.id == postId);
        if (index != -1) {
          _posts[index] = Post.fromJson(updatedPost);
        }
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
        backgroundColor: darkColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
          side: BorderSide(color: accentColor),
        ),
        title: Text(
          'Poszt módosítása',
          style: TextStyle(
            color: accentColor,
          ),
        ),

        content: TextField(
          style: TextStyle(color: whiteColor),
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Új tartalom',
            labelStyle: TextStyle(color: accentColor),
          ),
          maxLines: 15,
          keyboardType: TextInputType.multiline,
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

  final accentColor = const Color(0xFFFF204E);
  final darkColor = const Color(0xFF00224D);
  final whiteColor = Colors.white;

  // Egy poszt widgetjének megjelenítése
  Widget _buildPostItem(Post post) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: darkColor,
        border: Border.all(color: accentColor),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 20,
            color: accentColor,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    post.createdAt.substring(0, 10),
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: whiteColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (post.mediaUrl != null) ...[
            Image.network('https://kovacscsabi.moriczcloud.hu/' + post.mediaUrl!),
            Container(
              height: 2,
              color: accentColor,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                post.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  post.content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Hozzászólás gomb (jelenleg csak nyomtat egy üzenetet)
              ElevatedButton.icon(
                onPressed: () {
                  print('Hozzászólás gomb megnyomva');
                },
                icon: Icon(Icons.comment_sharp, size: 15),
                label: Text('Szólj hozzá'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkColor,
                  foregroundColor: whiteColor,
                  side: BorderSide(color: accentColor),
                ),
              ),
              Row(
                children: [
                  // Módosítás gomb
                  IconButton (
                    onPressed: () => _showUpdateDialog(post),
                    icon: Icon(Icons.edit_sharp, size: 15, color: accentColor),

                  ),
                  SizedBox(width: 8),
                  // Törlés gomb
                  IconButton(
                    onPressed: () => deletePost(post.id),
                    icon: Icon(Icons.delete_sharp, size: 15, color: accentColor),

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
      _currentPage = 1;
      _hasMore = true;
    });
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Posztok'),
      ),
      body: _hasError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$_errorMessage'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPosts,
              child: Text('Újrapróbálkozás'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _refreshPosts,
        child: _posts.isEmpty && _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _posts.isEmpty
            ? const Center(child: Text('Nincsenek posztok'))
            : ListView.builder(
          controller: _scrollController,
          itemCount: _posts.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == _posts.length) {
              return _hasMore
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
                  : const SizedBox();
            }
            return _buildPostItem(_posts[index]);
          },
        ),
      ),
    );
  }
}