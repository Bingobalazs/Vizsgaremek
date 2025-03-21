import 'package:flutter/material.dart';
import 'package:blabber/models/Post.dart';
import 'package:blabber/services/posts_api_service.dart';


class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Post>> futurePosts;

  @override
  void initState() {
    super.initState();
    futurePosts = PostsApiService().fetchFeed();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
      ),
      body: FutureBuilder<List<Post>>(
        future: futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No posts available'));
          }

          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return PostWidget(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}

class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late Future<bool> isLikedFuture;
  late Future<int> commentCountFuture;

  @override
  void initState() {
    super.initState();
    isLikedFuture = PostsApiService().checkLike(widget.post.id);
    commentCountFuture = PostsApiService().getCommentCount(widget.post.id);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.post.content, style: const TextStyle(fontSize: 16)),
            if (widget.post.mediaUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(widget.post.mediaUrl!),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                'Posted on ${widget.post.createdAt}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Like Button
                FutureBuilder<bool>(
                  future: isLikedFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error, color: Colors.red);
                    }
                    bool isLiked = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: () async {
                        try {
                          bool newLikeStatus = await PostsApiService().toggleLike(widget.post.id);
                          setState(() {
                            isLikedFuture = Future.value(newLikeStatus);
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error toggling like: $e')),
                          );
                        }
                      },
                    );
                  },
                ),
                // Comments Button
                FutureBuilder<int>(
                  future: commentCountFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Icon(Icons.error, color: Colors.red);
                    }
                    int count = snapshot.data ?? 0;
                    return TextButton(
                      onPressed: () {
                        // Navigate to comments screen with post ID (to be implemented)
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => CommentsScreen(postId: widget.post.id),
                        //   ),
                        // );
                      },
                      child: Text('Comments ($count)'),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}