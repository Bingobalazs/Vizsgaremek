
class Post {
  final int id;
  final String content;
  final String? mediaUrl;
  final String createdAt;
  final String userName;
   bool isLiked;
   bool isUnseen;
   int likeCount;

  Post({
    required this.id,
    required this.content,
    this.mediaUrl,
    required this.createdAt,
    required this.userName,
    required this.isLiked,
    required this.likeCount,
    required this.isUnseen,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      mediaUrl: json['media_url'],
      createdAt: json['created_at'],
      userName: json['user']['name'],
      isLiked: json['is_liked'],
      likeCount: json['like_count'],
      isUnseen: json['is_unseen'] ?? false,
    );
  }
}