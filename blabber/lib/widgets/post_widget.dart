import 'package:flutter/material.dart';
import 'package:blabber/models/Post.dart';
import 'package:blabber/services/posts_api_service.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:blabber/screens/comment_screen.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget({Key? key, required this.post}) : super(key: key);

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late Future<bool> isLikedFuture;
  late Future<int> commentCountFuture;
  bool _hasViewed = false; // Csak egyszer jelöljük meg, hogy láttuk

  @override
  void initState() {
    super.initState();
    isLikedFuture = PostsApiService().checkLike(widget.post.id);
    commentCountFuture = PostsApiService().getCommentCount(widget.post.id);
  }

  // Kiszámolja, hány nap telt el a poszt létrejötte óta
  String _calculateDaysAgo(String createdAt) {
    DateTime postDate = DateTime.parse(createdAt);
    DateTime now = DateTime.now();
    int days = now.difference(postDate).inDays;
    return days == 0 ? 'Today' : '$days days ago';
  }

  // Ha a widget legalább 50%-ban látható, jelöljük meg, hogy megnéztük
  void _onVisibilityChanged(VisibilityInfo info) {
    if (info.visibleFraction > 0.5 && !_hasViewed) {
      _hasViewed = true;
      PostsApiService().markView(widget.post.id).catchError((e) {
        // Hibakezelés opcionális
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = const Color(0xFFFF204E);
    final darkColor = const Color(0xFF00224D);
    final whiteColor = Colors.white;

    return VisibilityDetector(
      key: Key('post-widget-${widget.post.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: LayoutBuilder(
        builder: (context, constraints) {
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
                    // Felső sáv: posztoló neve és a poszt létrejöttének ideje
                    Container(
                      decoration: BoxDecoration(
                        color: widget.post.isUnseen ? accentColor : darkColor,
                        border: const Border(
                          bottom: BorderSide(color: Colors.white),
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
                    // Poszt tartalma vagy média
                    if (widget.post.mediaUrl != null) ...[
                      Image.network(
                        'https://kovacscsabi.moriczcloud.hu/${widget.post.mediaUrl!}',
                        fit: BoxFit.cover,
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
                    // Like gomb és hozzászólás ikon (fehér)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Like gomb
                          Row(
                            mainAxisSize: MainAxisSize.min,
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
                            ],
                          ),
                          // Hozzászólás ikon (fehér)
                          IconButton(
                            icon: Icon(
                              Icons.comment,
                              color: whiteColor, // Fehér színű ikon
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
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
