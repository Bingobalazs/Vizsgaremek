import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blabber/models/Post.dart';
import 'package:blabber/widgets/post_widget.dart';

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
  List<Post> _posts = [];
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
        'https://kovacscsabi.moriczcloud.hu/api/search/$query?page=1');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);

        // decodedJson is a Map according to your API structure.
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
        // Dismiss keyboard when tapping outside input
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
                // Search Field
                Container(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _textController,
                    focusNode: _textFieldFocusNode,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Search people, posts, and more...',
                      hintStyle:
                      bodyMediumStyle.copyWith(color: secondaryTextColor),
                      filled: true,
                      fillColor: secondaryColor,
                      prefixIcon:
                      Icon(Icons.search_rounded, color: accentColor),
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
                // Error Message
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: errorColor),
                  ),
                // Loading Indicator
                if (_isLoading) const Center(child: CircularProgressIndicator()),
                // Users Section
                if (!_isLoading && _users.isNotEmpty) ...[
                  Text('Felhasználók', style: titleMediumStyle),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _users
                          .map(
                            (user) => Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: _buildPersonCard(user, context),
                        ),
                      )
                          .toList(),
                    ),
                  ),
                ],
                // Posts Section
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
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) {
                        // Use your custom PostWidget.
                        return PostWidget(post: _posts[index]);
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 10);
                      },
                    ),
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
              image:
              NetworkImage('https://picsum.photos/500/500?person=${user.id}'),
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
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0)),
            elevation: 0,
          ),
        ),
      ],
    );
  }
}

/// Models for the API response ///

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

/// Update the PostsResult to handle a List directly.
class PostsResult {
  final List<Post> data;

  PostsResult({required this.data});

  factory PostsResult.fromJson(dynamic json) {
    // If json is a List, map directly; if it's a Map with a 'data' key, use that.
    if (json is List) {
      return PostsResult(data: json.map<Post>((item) => Post.fromJson(item)).toList());
    } else if (json is Map<String, dynamic> && json.containsKey('data')) {
      final List<dynamic> dataList = json['data'];
      final List<Post> posts =
      dataList.map((item) => Post.fromJson(item)).toList();
      return PostsResult(data: posts);
    } else {
      throw Exception("Unexpected posts JSON format");
    }
  }
}

class UserData {
  final int id;
  final String name;

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
