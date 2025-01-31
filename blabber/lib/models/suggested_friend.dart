class SuggestedFriend {
  final int id;
  final String name;


  SuggestedFriend({required this.id, required this.name});

  factory SuggestedFriend.fromJson(Map<String, dynamic> json) {
    return SuggestedFriend(
      id: json['id'],
      name: json['name'],

    );
  }
}
