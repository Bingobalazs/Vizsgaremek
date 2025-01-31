import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/suggested_friend.dart';
import '../models/user.dart';

class GetSuggestedFriends {
  static const String apiUrl = 'https://kovacscsabi.moriczcloud.hu/users';


  static Future<List<SuggestedFriend>> fetchFriendSuggestions() async {
  try{
    final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => SuggestedFriend.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load friends');
      }
    } catch (e) {
      throw Exception('Failed to aaaaaaaaaa: $e');
  }
  }
}
class GetUser {
  static const String baseUrl = 'https://your-api.com/api';

  // Fetch user data
  static Future<User> fetchUserProfile() async {
    final response = await http.get(Uri.parse('$baseUrl/user'));

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  // Update user data
  static Future<bool> updateUserProfile(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/user/update'),
      headers: {"Content-Type": "application/json"},
      body: json.encode(user.toJson()),
    );

    return response.statusCode == 200;
  }
}