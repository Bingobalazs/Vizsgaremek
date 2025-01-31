class User {
  String name;
  String email;
  String password;
  bool isPublic;

  User({
    required this.name,
    required this.email,
    required this.password,
    required this.isPublic,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'],
      email: json['email'],
      password: '',
      isPublic: json['isPublic'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "email": email,
      "password": password.isNotEmpty ? password : null,
      "isPublic": isPublic,
    };
  }
}
