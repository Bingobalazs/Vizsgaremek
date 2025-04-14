import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Chat üzenet modellje
class ChatMessage {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'].toString(),
      senderId: json['from_id'].toString(),
      receiverId: json['to_id'].toString(),
      message: json['chat'].toString(),
      timestamp: DateTime.parse(json['created_at']),
    );
  }
}

// Token lekérése a SharedPreferences-ből
Future<String> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) throw Exception('No token found');
  return token;
}

class Chat extends StatefulWidget {
  final String userId;
  final String friendId;
  final String friendName;

  const Chat({
    Key? key,
    required this.userId,
    required this.friendId,
    required this.friendName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchMessages(page: 1).then((_) {
      _scrollToBottom();
    });
  }

  // Ha a lista tetejére görgetünk, pl. régebbi üzenetek betöltése
  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 50) {
      _fetchMessages(page: 1, prepend: true);
    }
  }

  // Üzenetek lekérése a szerverről az API specifikációja alapján
  Future<void> _fetchMessages({required int page, bool prepend = false}) async {
    String token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse(
            'https://kovacscsabi.moriczcloud.hu/api/getchat/${widget.friendId}?page=$page'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        List<dynamic> dataList = decodedData['data'] ?? [];
        List<ChatMessage> fetchedMessages = dataList
            .map<ChatMessage>((json) => ChatMessage.fromJson(json))
            .toList();

        setState(() {
          if (prepend) {
            _messages.insertAll(0, fetchedMessages);
          } else {
            _messages = fetchedMessages;
          }
        });
      } else {
        _showSnackBar('Failed to fetch messages');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Üzenet küldése
  void _sendMessage() async {
    String token = await _getToken();
    if (_messageController.text.trim().isEmpty) {
      _showSnackBar('Message cannot be empty');
      return;
    }
    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Optimista frissítés: ideiglenesen hozzáadjuk az elküldött üzenetet.
    // Itt a receiverId a beszélgetés partnerének azonosítója, így később a feltétel szerint jobbra lesz igazítva.
    final optimisticMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: widget.userId,
      receiverId: widget.friendId,
      message: messageText,
      timestamp: DateTime.now(),
    );
    setState(() {
      _messages.add(optimisticMessage);
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(
            'https://kovacscsabi.moriczcloud.hu/api/postchat/${widget.friendId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'chat': messageText}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        setState(() {
          _messages.remove(optimisticMessage);
        });
      }
    } catch (e) {
      setState(() {
        _messages.remove(optimisticMessage);
      });
    }
  }

  // Lista legaljára ugrás, hogy a legfrissebb üzenet látható legyen
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Hibaüzenetek megjelenítése Snackbar segítségével
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      // Ha a paraméterként kapott friendId megegyezik
                      // az apiból kapott to_id-vel (receiverId), akkor jobbra igazítjuk.
                      final bool isRightAligned =
                          message.receiverId == widget.friendId;

                      // Dátum formázás: ha az üzenet nem a mai napon történt, akkor a dátum is megjelenik.
                      final now = DateTime.now();
                      final bool showDate = message.timestamp.year != now.year ||
                          message.timestamp.month != now.month ||
                          message.timestamp.day != now.day;

                      return Align(
                        alignment: isRightAligned
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 4.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: isRightAligned
                                ? Colors.blue
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                message.message,
                                style: TextStyle(
                                  color: isRightAligned
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              SizedBox(height: 4.0),
                              Text(
                                showDate
                                    ? '${message.timestamp.day}.${message.timestamp.month}.${message.timestamp.year} ${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}'
                                    : '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  color: isRightAligned
                                      ? Colors.white70
                                      : Colors.black54,
                                  fontSize: 10.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: Icon(Icons.send),
                  mini: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
