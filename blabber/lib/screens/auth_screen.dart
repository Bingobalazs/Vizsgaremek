import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bejelentkezés',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _deviceController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final response = await Dio().post(
        'https://kovacscsabi.moriczcloud.hu/api/login',
        data: {
          'email': _emailController.text,
          'password': _passwordController.text,
          'device_name': _deviceController.text,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final String token = data['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sikeres bejelentkezés!')),
        );
      } else {
        setState(() {
          _errorMessage = response.data['message'];
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hiba történt a bejelentkezés során';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bejelentkezés')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Jelszó'),
              obscureText: true,
            ),
            TextField(
              controller: _deviceController,
              decoration: InputDecoration(labelText: 'Eszköz neve'),
            ),
            SizedBox(height: 20),
            if (_errorMessage != null) Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            if (_loading)
              CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: _login,
                child: Text('Bejelentkezés'),
              ),
          ],
        ),
      ),
    );
  }
}