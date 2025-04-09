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
                  Text('Felhasználók', style: titleMediumStyle),
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
                  const SizedBox(height: 12
                  ),
                  //BEJEGYZÉSEK
                  ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(10.0),
                    itemCount: _posts.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index < _posts.length) {
                        return PostWidget(post: _posts[index]);
                      } else {
                        // Display a loading indicator at the bottom
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                    separatorBuilder: (context, index) {
                      // Insert a separator if transitioning from unseen to seen posts
                      if (index < _posts.length - 1) {

                      }
                      return const SizedBox(height: 10);
                    },
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
    LayoutBuilder(builder: (context, constraints) {
        return Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Container(
              width: constraints.maxWidth * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: accentColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar with poster's name and post age
                  Container(
                    decoration: BoxDecoration(
                      color: widget.post.isUnseen? accentColor : darkColor,
                      border: Border(
                        bottom: BorderSide(color: accentColor),
                      ),
                    ),

                    padding: const EdgeInsets.all(8.0),
                    width: double.infinity,
                    child: Text(
                      '${widget.post.userName} • ${_calculateDaysAgo(widget.post.createdAt)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Post content or media
                  if (widget.post.mediaUrl != null) ...[
                    Image.network(widget.post.mediaUrl!),
                    Container(
                      height: 2,
                      color: accentColor,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.post.content,
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
                          widget.post.content,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Like and Comment buttons
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Like Button
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                widget.post.isLiked
                                    ? Icons.thumb_up_off_alt_sharp
                                    : Icons.thumb_up_off_alt_outlined,
                                color: widget.post.isLiked ? accentColor : whiteColor,
                              ),
                              onPressed: () async {
                                try {
                                  bool newLikeStatus = await PostsApiService().toggleLike(widget.post.id);
                                  setState(() {
                                    widget.post.isLiked = newLikeStatus;
                                    widget.post.likeCount += newLikeStatus ? 1 : -1;
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error toggling like: $e')),
                                  );
                                }
                              },
                            ),
                            Text(
                              '${widget.post.likeCount}',
                              style: TextStyle(color: whiteColor),
                            ),
                          ],
                        ),
                        // Comment Button
                        FutureBuilder<int>(
                          future: commentCountFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator(color: accentColor);
                            } else if (snapshot.hasError) {
                              return Icon(Icons.error, color: accentColor);
                            }
                            int count = snapshot.data ?? 0;
                            return TextButton.icon(
                              icon: Icon(Icons.comment, color: darkColor),
                              label: Text(
                                'Szólj hozzá... ($count)',
                                style: TextStyle(color: darkColor),
                              ),
                              style: TextButton.styleFrom(
                                backgroundColor: whiteColor,
                                side: BorderSide(color: accentColor),
                                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                              ),
                              onPressed: () {
                                // Navigation to comments screen can be added here.
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),


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