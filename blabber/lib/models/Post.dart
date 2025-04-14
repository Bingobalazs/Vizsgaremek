class Post {
  final int id;
  final int userId; // Új mező a posztoló azonosítójához
  final String content;
  final String? mediaUrl;
  final String createdAt;
  final String userName;
  bool isLiked;
  bool isUnseen;
  int likeCount;

  Post({
    required this.id,
    required this.userId,
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
      userId: json['user_id'] ??
          json['user'][
              'id'], // Az API "user_id" mezője vagy ha nem létezik, a nested "user" objektum "id"-ja
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
