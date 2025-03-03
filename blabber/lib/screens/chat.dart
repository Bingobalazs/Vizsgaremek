import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Chat extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<Chat> {
  List users = []; // Ebben tároljuk a felhasználókat

  @override
  void initState() {
    super.initState();
    fetchUsers(); // API hívás betöltéskor
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('https://kovacscsabi.moriczcloud.hu/api/friends/34')); //34 az a tj id-ja, majd ki kell cserélni az auth-ra

    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body); // JSON konvertálása List-é
      });
    } else {
      throw Exception('Nem sikerült az adatok lekérése');
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(title: Text('${args['name']}')));
  }
}

void main() {
  runApp(MaterialApp(
    home: Chat(),
  ));
}
