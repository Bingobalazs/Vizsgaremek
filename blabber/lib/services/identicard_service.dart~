import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:blabber/models/identicard.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdenticardService {
  final String baseUrl = 'https://kovacscsabi.moriczcloud.hu/api/identicard';

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<bool> checkExists() async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/check'), headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['exists'] ?? false;
    } else {
      throw Exception('Failed to check Identicard existence');
    }
  }

  Future<Identicard> getIdenticard(String username) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl/get/$username'), headers: headers);
    if (response.statusCode == 200) {
      return Identicard.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch Identicard');
    }
  }

  Future<void> addIdenticard(Identicard identicard) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: headers,
      body: jsonEncode(identicard.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add Identicard');
    }
  }

  Future<void> updateIdenticard(Identicard identicard) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/update'),
      headers: headers,
      body: jsonEncode(identicard.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update Identicard');
    }
  }
}