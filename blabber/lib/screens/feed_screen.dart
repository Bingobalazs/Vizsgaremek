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

  // Calculate days since the post was created
  String _calculateDaysAgo(String createdAt) {
    DateTime postDate = DateTime.parse(createdAt);
    DateTime now = DateTime.now();
    int days = now.difference(postDate).inDays;
    return days == 0 ? 'Today' : '$days days ago';
  }

  @override
  Widget build(BuildContext context) {
    // Define colors
    final accentColor = Color(0xFFFF204E);
    final darkColor = Color(0xFF00224D);
    final whiteColor = Colors.white;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: accentColor), // Accent color border around the widget
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar with poster's name and post age
          Container(
            color: accentColor, // Accent color background
            padding: const EdgeInsets.all(8.0),
            width: double.infinity,
            child: Text(
              '${widget.post.userName} • ${_calculateDaysAgo(widget.post.createdAt)}',
              style: const TextStyle(
                color: Colors.white, // White text
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Post content or media
          if (widget.post.mediaUrl != null) ...[
            // Display media if present
            Image.network(widget.post.mediaUrl!),
            // Accent color separator line
            Container(
              height: 2,
              color: accentColor,
            ),
            // Post content in smaller white text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.post.content,
                style: const TextStyle(
                  color: Colors.white, // White text
                  fontSize: 14, // Smaller size
                ),
              ),
            ),
          ] else ...[
            // No media: display content in larger accent color text
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.post.content,
                style: TextStyle(
                  color: accentColor, // Accent color text
                  fontSize: 18, // Larger size
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
                FutureBuilder<bool>(
                  future: isLikedFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(color: accentColor);
                    } else if (snapshot.hasError) {
                      return Icon(Icons.error, color: accentColor);
                    }
                    bool isLiked = snapshot.data ?? false;
                    return IconButton(
                      icon: Icon(
                        isLiked ? Icons.thumb_up_off_alt_sharp: Icons.thumb_up_off_alt_outlined, // Always use thumb_up_off_alt
                        color: isLiked ? accentColor : whiteColor, // Accent when liked, dark otherwise
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
                      icon: Icon(Icons.comment, color: darkColor), // Comment icon in dark color
                      label: Text(
                        'Szólj hozzá... ($count)',
                        style: TextStyle(color: darkColor), // Dark color text
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: whiteColor, // White background
                        side: BorderSide(color: accentColor), // Accent color border
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      ),
                      onPressed: () {
                        // Add navigation to comments screen here if needed
                        // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => CommentsScreen(postId: widget.post.id)));
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}








