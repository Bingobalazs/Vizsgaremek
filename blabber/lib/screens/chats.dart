import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Chats extends StatefulWidget {
  final int userId;

  const Chats({super.key, required this.userId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<Chats> {
  List<Map<String, dynamic>> friends = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final String apiUrl =
        'https://kovacscsabi.moriczcloud.hu/api/friends/${widget.userId}';

    try {
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          friends = data
              .map((e) => {
                    'id': e['id'],
                    'friendId': e['user_id'] == widget.userId
                        ? e['other_user_id']
                        : e['user_id'],
                    'created_at': e['created_at'],
                  })
              .toList();
        });
      } else {
        throw Exception('Hiba: ${response.statusCode}');
      }
    } catch (error) {
      setState(() {
        errorMessage = 'Nem sikerült betölteni a barátokat!';
        friends = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Barátok listája')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red, fontSize: 16)))
              : ListView.builder(
                  itemCount: friends.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.person),
                      title:
                          Text('Felhasználó ID: ${friends[index]['friendId']}'),
                      subtitle: Text(
                          'Ismeretség kezdete: ${friends[index]['created_at']}'),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchFriends,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
