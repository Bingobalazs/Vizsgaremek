import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:blabber/models/Post.dart';

class FeedResponse {
  final List<Post> posts;
  final bool hasMore;

  FeedResponse({required this.posts, required this.hasMore});
}
class PostsApiService {
  static const String baseUrl = 'https://kovacscsabi.moriczcloud.hu/api'; // Replace with your API URL

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) throw Exception('No token found');
    return token;
  }

  // Fetch feed posts with pagination support
  Future<FeedResponse> fetchFeed({int page = 1}) async {
    String token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/posts?page=$page'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      List jsonResponse = body['posts'];
      bool hasMore = body['has_more'];
      List<Post> posts = jsonResponse.map((post) => Post.fromJson(post)).toList();
      return FeedResponse(posts: posts, hasMore: hasMore);
    } else {
      throw Exception('Failed to load feed');
    }
  }

  // Check if post is liked
  Future<bool> checkLike(int postId) async {
    String token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/like/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['is_liked'];
    } else {
      throw Exception('Failed to check like');
    }
  }

  // Toggle like status
  Future<bool> toggleLike(int postId) async {
    String token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/like/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['is_liked'];
    } else {
      throw Exception('Failed to toggle like');
    }
  }

  // Get comment count
  Future<int> getCommentCount(int postId) async {
    String token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/count/comment/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      return json.decode(response.body)['count'];
    } else {
      throw Exception('Failed to get comment count');
    }
  }

  // Mark that a post was viewed
  Future<void> markView(int postId) async {
    String token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/view/$postId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to mark post view');
    }
  }
}