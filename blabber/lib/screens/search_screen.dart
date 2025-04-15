import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blabber/models/Post.dart';
import 'package:blabber/widgets/post_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Define your color palette - replace these with your actual colors
const Color primaryColor = Color(0xFF007BFF);
const Color secondaryColor = Color.fromRGBO(0, 34, 77, 1);
const Color accentColor = Color.fromRGBO(255, 32, 78, 1);
const Color primaryTextColor = Colors.white;
const Color secondaryTextColor = Colors.grey;
const Color errorColor = Colors.red;

Future<String> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) throw Exception('Nincs bejelentkezve');
  return token;
}


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
  List<Post> _allPosts = [];
  List<Post> _displayedPosts = [];
  Timer? _debounce;
  bool _isLoading = false;
  bool _isLoadingMorePosts = false;
  String _errorMessage = '';
  int _postCurrentPage = 1;
  bool _hasMorePosts = true;
  final ScrollController _scrollController = ScrollController();
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onSearchChanged);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final query = _textController.text;
      if (query.length > 1) {
        _currentQuery = query;
        _resetSearch();
        _fetchSearchResults(query);
      } else {
        _resetSearch();
      }
    });
  }

  void _resetSearch() {
    setState(() {
      _users.clear();
      _allPosts.clear();
      _displayedPosts.clear();
      _postCurrentPage = 1;
      _hasMorePosts = true;
      _errorMessage = '';
    });
  }

  Future<void> _fetchSearchResults(String query, {int page = 1}) async {
    setState(() {
      if (page == 1) {
        _isLoading = true;
        _errorMessage = '';
      } else {
        _isLoadingMorePosts = true;
      }
    });

    final url = Uri.parse(
        'https://kovacscsabi.moriczcloud.hu/api/search/$query?page=$page');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        final searchResult = SearchResult.fromJson(decodedJson);

        setState(() {
          if (page == 1) {
            _users = searchResult.users.data;
            _allPosts = searchResult.posts.data;
            _displayedPosts = _allPosts.take(10).toList();
            _postCurrentPage = 1;
            _hasMorePosts = searchResult.posts.pagination?.currentPage != null &&
                searchResult.posts.pagination?.lastPage != null &&
                searchResult.posts.pagination!.currentPage < searchResult.posts.pagination!.lastPage;
          } else {
            _allPosts.addAll(searchResult.posts.data);
            _displayedPosts = _allPosts;
            _hasMorePosts = searchResult.posts.pagination?.currentPage != null &&
                searchResult.posts.pagination?.lastPage != null &&
                searchResult.posts.pagination!.currentPage < searchResult.posts.pagination!.lastPage;
          }
        });
      } else {
        setState(() {
          _errorMessage =
          'Failed to fetch data. Status code: ${response.statusCode}';
          _hasMorePosts = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: $e';
        _hasMorePosts = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMorePosts = false;
        });
      }
    }
  }

  void _onScroll() {
    if (_hasMorePosts &&
        !_isLoadingMorePosts &&
        _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
      _postCurrentPage++;
      _fetchSearchResults(_currentQuery, page: _postCurrentPage);
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
                const SizedBox(height: 16),

                // Search Field
                Container(
                  width: double.infinity,
                  child: TextFormField(
                    controller: _textController,
                    focusNode: _textFieldFocusNode,
                    autofocus: false,
                    decoration: InputDecoration(
                      hintText: 'Keress embereket és posztokat...',
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
                // Loading Indicator (initial search)
                if (_isLoading && _users.isEmpty && _allPosts.isEmpty)
                  const Center(child: CircularProgressIndicator()),
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
                  const SizedBox(height: 12),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: accentColor,
                  ),
                ],
                // Posts Section
                if (!_isLoading && (_displayedPosts.isNotEmpty || _isLoadingMorePosts || !_hasMorePosts)) ...[
                  const SizedBox(height: 12),
                  Text('Bejegyzések', style: titleMediumStyle),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(10.0),
                          itemCount: _displayedPosts.length,
                          itemBuilder: (context, index) {
                            return PostWidget(post: _displayedPosts[index]);
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 10);
                          },
                        ),
                        if (_isLoadingMorePosts)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          ),
                        if (!_hasMorePosts && _displayedPosts.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(''),
                          ),
                      ],
                    ),
                  ),
                ],
                if (!_isLoading && _users.isEmpty && _displayedPosts.isEmpty && _errorMessage.isEmpty && _textController.text.length > 1)
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Nincs találat.',
                        style: TextStyle(color: secondaryTextColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonCard(UserData user, BuildContext context) {
    bool _isMarked = false;
    //TODO: ez nem működik így majd talán ha lesz api
    // Lehet inkább egyszerűbb lenne nem itt jelölni, csak a részletes oldalon


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
              //TODO: Replace with actual image
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
          onPressed: () async {
            setState(() {
              _isLoading = true;
            });

            try {
              String token = await _getToken();

              final response = await http.post(
                Uri.parse('https://kovacscsabi.moriczcloud.hu/api/jeloles/${user.id}'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
              );

              if (response.statusCode == 200) {
                setState(() {
                  _isMarked = true;
                  _isLoading = false;
                });
              } else {
                // Handle error
                print('Failed to mark: ${response.statusCode}');
                setState(() {
                  _isLoading = false;
                });
              }
            } catch (e) {
              print('Error: $e');
              setState(() {
                _isLoading = false;
              });
            }
          },
          label: Text(
              _isMarked ? 'Mégse' : 'Jelölés',
              style: TextStyle(fontSize: 12)
          ),
          icon: _isLoading
              ? SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : Icon(
              _isMarked ? Icons.close : Icons.add,
              size: 16
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _isMarked ? Colors.red : accentColor,
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
  final PaginatedPostsResult posts;

  SearchResult({
    required this.users,
    required this.posts,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      users: UsersResult.fromJson(json['users']),
      posts: PaginatedPostsResult.fromJson(json['posts']),
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

class PaginatedPostsResult {
  final List<Post> data;
  final Pagination? pagination;

  PaginatedPostsResult({required this.data, this.pagination});

  factory PaginatedPostsResult.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      final List<dynamic> dataList = json['data'];
      final List<Post> posts =
      dataList.map((item) => Post.fromJson(item)).toList();
      return PaginatedPostsResult(
        data: posts,
        pagination: json.containsKey('links')
            ? Pagination.fromJson(json)
            : null,
      );
    } else {
      // Handle case where 'posts' might directly be a list (though your structure suggests otherwise)
      return PaginatedPostsResult(
          data: (json as List).map((item) => Post.fromJson(item)).toList());
    }
  }
}

class Pagination {
  final int currentPage;
  final int lastPage;

  Pagination({required this.currentPage, required this.lastPage});

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
    );
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