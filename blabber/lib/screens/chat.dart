import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class ApiService {
  Future<Map<String, dynamic>> fetchData(String param1, String param2, String param3) async {
    Uri url = Uri.parse('https://kovacscsabi.hu/$param1/$param2/$param3');
    
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class Chat extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<Chat> {
  final ApiService apiService = ApiService();
  late String param1, param2, param3;
  bool isLoading = false;
  Map<String, dynamic>? data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
    param1 = args['param1']!;
    param2 = args['param2']!;
    param3 = args['param3']!;
  }

  void fetchData() async {
    setState(() => isLoading = true);
    try {
      var result = await apiService.fetchData(param1, param2, param3);
      setState(() => data = result);
    } catch (e) {
      showErrorDialog(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hiba'),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('API Adatok')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(onPressed: fetchData, child: Text('API Hívás')),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : data != null
                    ? Expanded(
                        child: ListView(
                          children: data!.entries.map((entry) => ListTile(title: Text('${entry.key}: ${entry.value}'))).toList(),
                        ),
                      )
                    : Container(),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter API Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      routes: {'/dataScreen': (context) => Chat()},
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Főoldal')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/dataScreen',
              arguments: {'param1': 'value1', 'param2': 'value2', 'param3': 'value3'},
            );
          },
          child: Text('Navigálás az adat képernyőre'),
        ),
      ),
    );
  }
}
