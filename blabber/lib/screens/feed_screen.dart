import 'package:flutter/material.dart';
import 'package:blabber/models/Post.dart';
import 'package:blabber/services/posts_api_service.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../widgets/post_widget.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Post> _posts = [];
  bool _hasMore = true;
  int _page = 1;
  bool _isLoading = false;
  final PostsApiService _apiService = PostsApiService();

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Ha már a lista aljához közelítünk, betöltjük a következő posztcsomagot
  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMore) {
      _loadPosts();
    }
  }

  // Posztok betöltése az API-ból
  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final feedResponse = await _apiService.fetchFeed(page: _page);
      setState(() {
        _page++;
        _posts.addAll(feedResponse.posts);
        _hasMore = feedResponse.hasMore;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading posts: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Pull-to-refresh funkció
  Future<void> _refreshPosts() async {
    setState(() {
      _posts.clear();
      _page = 1;
      _hasMore = true;
    });
    await _loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: ListView.separated(
          controller: _scrollController,
          padding: const EdgeInsets.all(10.0),
          itemCount: _posts.length + (_hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index < _posts.length) {
              return PostWidget(post: _posts[index]);
            } else {
              // Alsó mutató, ha még töltünk
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
          },
          separatorBuilder: (context, index) {
            // Ha az elválasztó olyan posztok között kerül, ahol a látottság változik
            if (index < _posts.length - 1) {
              if (_posts[index].isUnseen && !_posts[index + 1].isUnseen) {
                return Column(
                  children: const [
                    SizedBox(height: 10),
                    Divider(color: Color(0xFFFF204E)),
                    Text("Older posts", style: TextStyle(color: Colors.white)),
                    SizedBox(height: 10),
                  ],
                );
              }
            }
            return const SizedBox(height: 10);
          },
        ),
      ),
    );
  }
}
