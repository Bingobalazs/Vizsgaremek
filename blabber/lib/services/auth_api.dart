import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {

  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<dynamic> get(String endpoint, token) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Accept': 'application/json', 'Authorization' : 'Bearer $token'},
    );
    print(token);
    return _handleResponse(response);
  }

  Future<dynamic> postWithToken(String endpoint, Map<String, dynamic> data, token) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Accept': 'application/json', 'Authorization' : 'Bearer $token'},
      body: data,
    );
    return _handleResponse(response);
  }


  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Accept': 'application/json'},
      body: data,
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'));
    return _handleResponse(response);
  }


  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      return jsonDecode(response.body);
    } else if (response.statusCode >= 500 && response.statusCode < 600) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }
}

