import 'package:flutter/material.dart';
import 'package:blabber/models/Post.dart';
import 'package:blabber/screens/user_screen.dart';
import 'package:blabber/services/posts_api_service.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../screens/comment_screen.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {

  late Future<int> commentCountFuture;
  bool _hasViewed = false; // To ensure we mark view only once

  @override
  void initState() {
    super.initState();

    commentCountFuture = PostsApiService().getCommentCount(widget.post.id);
  }

  // Calculate days since the post was created
  String _calculateDaysAgo(String createdAt) {
    DateTime postDate = DateTime.parse(createdAt);
    DateTime now = DateTime.now();
    int days = now.difference(postDate).inDays;
    return days == 0 ? 'Ma' : '$days napja';
  }

  // Call the view API when the post is visible
  void _onVisibilityChanged(VisibilityInfo info) {
    // If more than 50% of the widget is visible and we haven't already marked it as viewed
    if (info.visibleFraction > 0.5 && !_hasViewed) {
      _hasViewed = true;
      PostsApiService().markView(widget.post.id).catchError((e) {
        // Optionally handle error (e.g., log it)
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define colors
    final accentColor = const Color(0xFFFF204E);
    final darkColor = const Color(0xFF00224D);
    final whiteColor = Colors.white;

    return VisibilityDetector(
      key: Key('post-widget-${widget.post.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: LayoutBuilder(builder: (context, constraints) {
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
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: widget.post.isUnseen ? accentColor : darkColor,
                      border: Border(
                        bottom: BorderSide(color: accentColor),
                      ),
                    ),
                    child: InkWell(
                      splashColor: accentColor,
                      highlightColor: accentColor,
                      hoverColor: accentColor,
                      focusColor: accentColor,

                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                UserScreen(userId: widget.post.userId.toString()),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          '${widget.post.userName} • ${_calculateDaysAgo(widget.post.createdAt)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Post content or media
                  if (widget.post.mediaUrl != null) ...[
                    Center(
                      child:
                    Image.network('https://kovacscsabi.moriczcloud.hu/' +
                        widget.post.mediaUrl!),

                    ),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Like Button
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: Icon(
                                widget.post.isLiked
                                    ? Icons.thumb_up_off_alt_sharp
                                    : Icons.thumb_up_off_alt_outlined,
                                color: widget.post.isLiked
                                    ? accentColor
                                    : whiteColor,
                              ),
                              onPressed: () async {
                                try {
                                  bool newLikeStatus = await PostsApiService()
                                      .toggleLike(widget.post.id);
                                  setState(() {
                                    widget.post.isLiked = newLikeStatus;
                                    widget.post.likeCount +=
                                        newLikeStatus ? 1 : -1;
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content:
                                            Text('Error toggling like: $e')),
                                  );
                                }
                              },
                            ),
                            Text(
                              '${widget.post.likeCount}',
                              style: TextStyle(color: whiteColor),
                            ),
                            IconButton(
                    icon: Icon(
                      Icons.comment,
                      color: whiteColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CommentScreen(postId: widget.post.id),
                        ),

                      );
                    },
                  ),
                          ],
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
    );
  }
}
