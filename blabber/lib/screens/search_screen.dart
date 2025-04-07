import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Define your color palette - replace these with your actual colors
const Color primaryColor = Color(0xFF007BFF);
const Color secondaryColor = Color.fromRGBO(0, 34, 77, 1);
const Color accentColor = Color.fromRGBO(255, 32, 78, 1);
const Color primaryTextColor = Colors.white;
const Color secondaryTextColor = Colors.grey;
const Color errorColor = Colors.red;

// Define your text styles - replace these with your actual styles
final TextStyle titleMediumStyle = TextStyle(
  fontFamily: 'Roboto Mono',
  fontSize: 16,
  fontWeight: FontWeight.bold,
  letterSpacing: 0.0,
);

final TextStyle bodyMediumStyle = TextStyle(
  fontFamily: 'Roboto Mono',
  fontSize: 14,
  color: primaryTextColor,
  letterSpacing: 0.0,
);

final TextStyle bodySmallStyle = TextStyle(
  fontFamily: 'Roboto Mono',
  fontSize: 12,
  letterSpacing: 0.0,
);

final TextStyle titleSmallStyle = TextStyle(
  fontFamily: 'Roboto Mono',
  fontSize: 12,
  color: secondaryTextColor,
  letterSpacing: 0.0,
);

final TextStyle bodyLargeStyle = TextStyle(
  fontFamily: 'Roboto Mono',
  fontSize: 20,
  color: accentColor,
  letterSpacing: 0.0,
);




class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  static String routeName = 'search';
  static String routePath = '/search';

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _textController = TextEditingController();
  final _textFieldFocusNode = FocusNode();
  List<UserData> _users = [];
  List<PostData> _posts = [];
  Timer? _debounce;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_textController.text.length > 1) {
        _fetchSearchResults(_textController.text);
      } else {
        setState(() {
          _users.clear();
          _posts.clear();
        });
      }
    });
  }

  Future<void> _fetchSearchResults(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = Uri.parse(
        'https://kovacscsabi.moriczcloud.hu/api/search/$query?page=1'); // You might need to handle pagination

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        final searchResult = SearchResult.fromJson(decodedJson);

        setState(() {
          _users = searchResult.users.data;
          _posts = searchResult.posts.data;
        });
      } else {
        setState(() {
          _errorMessage =
          'Failed to fetch data. Status code: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: secondaryColor,
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _textController,
                    focusNode: _textFieldFocusNode,
                    autofocus: false,
                    obscureText: false,
                    decoration: InputDecoration(
                      hintText: 'Search people, posts, and more...',
                      hintStyle: bodyMediumStyle.copyWith(color: secondaryTextColor),
                      filled: true,
                      fillColor: secondaryColor,
                      prefixIcon: Icon(Icons.search_rounded, color: accentColor),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: accentColor, width: 1),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: accentColor, width: 1),
                        borderRadius: BorderRadius.zero,
                      ),
                      errorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: errorColor, width: 1),
                        borderRadius: BorderRadius.zero,
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: errorColor, width: 1),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    style: bodyMediumStyle,
                    cursorColor: accentColor,
                  ),
                ),
                const SizedBox(height: 16),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: errorColor),
                  ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (!_isLoading && _users.isNotEmpty) ...[
                  Text('Emberek', style: titleMediumStyle),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _users
                          .map((user) => Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: _buildPersonCard(user, context),
                      ))
                          .toList(),
                    ),
                  ),
                ],
                if (!_isLoading && _posts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: accentColor,
                  ),
                  const SizedBox(height: 12),
                  Text('Bejegyzések', style: titleMediumStyle),
                  const SizedBox(height: 12),
                  Column(
                    children: _posts
                        .map((post) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildPostCard(post, context),
                    ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonCard(UserData user, BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: NetworkImage(
                  'https://picsum.photos/500/500?person=${user.id}'), // Or a default image
            ),
            shape: BoxShape.rectangle,
            border: Border.all(color: accentColor, width: 2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.name,
          textAlign: TextAlign.center,
          style: bodyMediumStyle.copyWith(
            color: primaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: () {
            print('Button pressed ...');
          },
          label: const Text('Jelölés', style: TextStyle(fontSize: 12)),
          icon: const Icon(Icons.add, size: 16),
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildPostCard(PostData post, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      decoration: BoxDecoration(
        color: secondaryColor,
        border: Border.all(color: accentColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 20,
            color: accentColor,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Text(
                    'User ${post.userId}', // Or fetch the user's name
                    style: const TextStyle(
                      fontFamily: 'Roboto Mono',
                      color: secondaryColor,
                      fontSize: 12,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    post.createdAt.toString(), // Format this date
                    style: TextStyle(
                      fontFamily: 'Ubuntu',
                      color: secondaryTextColor,
                      letterSpacing: 0.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Text(
              post.content,
              textAlign: TextAlign.center,
              style: bodyLargeStyle,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4 * 0.7,
                height: MediaQuery.of(context).size.height * 0.05,
                color: secondaryColor,
                child: ElevatedButton.icon(
                  onPressed: () {
                    print('Comment button pressed ...');
                  },
                  icon: const Icon(Icons.comment_sharp, color: accentColor, size: 16),
                  label: Text('Szólj hozzá...', style: titleSmallStyle),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryColor,
                    foregroundColor: secondaryTextColor,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                      side: BorderSide(color: accentColor),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 5),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          print('Like button pressed ...');
                        },
                        icon: const Icon(Icons.thumb_up_outlined, size: 16),
                        label: const Text(
                          'LIKE',
                          style: TextStyle(
                            fontFamily: 'Roboto Mono',
                            color: secondaryColor,
                            fontSize: 16,
                            letterSpacing: 0.0,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor,
                          foregroundColor: Colors.white,
                          minimumSize: Size.zero,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          alignment: Alignment.centerLeft,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Data models to match the API response
class SearchResult {
  final UsersResult users;
  final PostsResult posts;

  SearchResult({
    required this.users,
    required this.posts,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      users: UsersResult.fromJson(json['users']),
      posts: PostsResult.fromJson(json['posts']),
    );
  }
}

class UsersResult {
  final List<UserData> data;
  // Add other pagination data if needed (e.g., currentPage, lastPage)

  UsersResult({
    required this.data,
  });

  factory UsersResult.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'];
    final List<UserData> users =
    dataList.map((item) => UserData.fromJson(item)).toList();
    return UsersResult(
      data: users,
    );
  }
}

class PostsResult {
  final List<PostData> data;
  // Add other pagination data if needed

  PostsResult({
    required this.data,
  });

  factory PostsResult.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'];
    final List<PostData> posts =
    dataList.map((item) => PostData.fromJson(item)).toList();
    return PostsResult(
      data: posts,
    );
  }
}

class UserData {
  final int id;
  final String name;
  // Add other user fields as needed

  UserData({
    required this.id,
    required this.name,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'],
    );
  }
}

class PostData {
  final int id;
  final int userId;
  final String content;
  final DateTime createdAt;
  // Add other post fields

  PostData({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory PostData.fromJson(Map<String, dynamic> json) {
    return PostData(
      id: json['id'],
      userId: json['user_id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}