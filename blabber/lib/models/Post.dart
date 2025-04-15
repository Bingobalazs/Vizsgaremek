class Post {
  final int id;
  final int? userId;
  final String content;
  final String? mediaUrl;
  final String createdAt;
  final String userName;
  bool isLiked;
  bool isUnseen;
  int likeCount;

  Post({
    required this.id,
    this.userId,
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
      userId: json['user']['id'],
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
