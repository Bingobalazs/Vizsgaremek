import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:blabber/models/identicard.dart';

class IdenticardService {
  static const String baseUrl = 'https://kovacscsabi.moriczcloud.hu/api/identicard';

  // Check if Identicard exists
  static Future<bool> checkIdenticardExists(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/check'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['exists'] ?? false;
    }
    throw Exception('Failed to check Identicard');
  }

  // Fetch Identicard data
  static Future<Identicard?> getIdenticard(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/get'),
      headers: {'Authorization': 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      return Identicard.fromJson(jsonDecode(response.body));
    }
    return null; // Return null if no Identicard exists
  }

  // Add new Identicard
  static Future<void> addIdenticard(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add Identicard: ${response.body}');
    }
  }

  // Update existing Identicard
  static Future<void> updateIdenticard(String token, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update Identicard: ${response.body}');
    }
  }
}