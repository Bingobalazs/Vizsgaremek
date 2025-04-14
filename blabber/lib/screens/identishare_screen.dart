import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IdentiCardScreen extends StatefulWidget {
  const IdentiCardScreen({Key? key}) : super(key: key);

  @override
  _IdentiCardScreenState createState() => _IdentiCardScreenState();
}

class _IdentiCardScreenState extends State<IdentiCardScreen> {
  bool _isLoading = true;
  bool _cardExists = false;
  String _username = '';
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkIdentiCard();
  }

  Future<void> _checkIdentiCard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('https://kovacscsabi.moriczcloud.hu/api/identicard/check'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final exists = data['exists'] as bool;

        setState(() {
          _cardExists = exists;
        });

        if (exists) {
          await _getIdentiCard();
        }
      } else {
        setState(() {
          _errorMessage = 'Sikertelen ellenőrzés. Státuszkód: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hiba történt: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getIdentiCard() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final response = await http.get(
        Uri.parse('https://kovacscsabi.moriczcloud.hu/api/identicard/get'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _username = data['username'] as String;
        });
      } else {
        setState(() {
          _errorMessage = 'IdentiCard lekérése sikertelen. Státuszkód: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Hiba történt: $e';
      });
    }
  }

  Future<void> _createIdentiCard() async {
    // Here you would implement the API call to create an IdentiCard
    // For now, let's just simulate it by refreshing the check
    await _checkIdentiCard();
  }

  void _shareIdentiCard() {
    if (_username.isNotEmpty) {
      final String url = 'https://kovacscsabi.moriczcloud.hu/identicard/$_username';
      Share.share('Itt van az IdentiCard-om: $url', subject: 'IdentiCard megosztás');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IdentiCard'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkIdentiCard,
              child: const Text('Újra próbálkozás'),
            ),
          ],
        ),
      )
          : _cardExists
          ? _buildIdentiCardView()
          : _buildNoCardView(),
    );
  }

  Widget _buildIdentiCardView() {
    final String qrUrl = 'https://kovacscsabi.moriczcloud.hu/identicard/$_username';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'A te IdentiCard-od',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: QrImageView(
              data: qrUrl,
              version: QrVersions.auto,
              size: 200.0,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Felhasználónév: $_username',
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Megosztás'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: _shareIdentiCard,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: qrUrl));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('URL másolva a vágólapra')),
              );
            },
            child: const Text('URL másolása'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoCardView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.credit_card_off,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nincs még IdentiCard-od',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _createIdentiCard,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text(
              'Készíts egyet',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}