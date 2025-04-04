import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

// ChatMessage modell
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

// Segédfüggvény a token lekéréséhez
Future<String> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) throw Exception('No token found');
  return token;
}

// Chat widget
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

  // WebSocket kapcsolat a reálidejű értesítésekhez.
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _connectWebSocket();
    _loadMessages();
  }

  // Kapcsolódás a WebSocket szerverhez.
  void _connectWebSocket() {
    // A saját környezetednek megfelelő URI-t add meg itt!
    _channel = WebSocketChannel.connect(
      Uri.parse(
        'wss://yourdomain.com:6001/app/YOUR_APP_KEY?protocol=7&client=js&version=4.4.7&flash=false',
      ),
    );

    _channel.stream.listen((data) {
      print('Received via WebSocket: $data');
      try {
        final decoded = jsonDecode(data);
        // Amennyiben az esemény adatai egy "chat" kulcs alatt érkeznek, azt használd,
        // különben a decoded objektumot használd közvetlenül.
        final chatData = decoded['chat'] ?? decoded;
        final newMessage = ChatMessage.fromJson(chatData);
        // Csak akkor adjuk hozzá, ha az üzenet a két adott felhasználó között van.
        if (newMessage.senderId == widget.friendId ||
            newMessage.senderId == widget.userId) {
          setState(() {
            _messages.add(newMessage);
          });
          _scrollToBottom();
        }
      } catch (e) {
        print('Error decoding WebSocket data: $e');
      }
    }, onError: (error) {
      print('WebSocket error: $error');
    }, onDone: () {
      print('WebSocket connection closed');
    });
  }

  // Előző üzenetek betöltése (HTTP)
  Future<void> _loadMessages() async {
    String token = await _getToken();
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://kovacscsabi.moriczcloud.hu/api/getchat/${widget.friendId}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _messages = data
              .map<ChatMessage>((json) => ChatMessage.fromJson(json))
              .toList();
        });
      } else {
        _showSnackBar(
            'Hiba történt az üzenetek betöltésekor: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Hiba: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  // Üzenet küldése
  void _sendMessage() async {
    String token = await _getToken();

    if (_messageController.text.trim().isEmpty) {
      _showSnackBar('Nem küldhetsz üres üzenetet!');
      return;
    }

    final messageText = _messageController.text.trim();
    _messageController.clear();

    // Optimista frissítés: az üzenet azonnal megjelenik a felületen.
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
      // A backenden történik az adatbázisba mentés és a WebSocket-en keresztüli broadcast.
      final response = await http.post(
        Uri.parse(
          'https://kovacscsabi.moriczcloud.hu/api/postchat/${widget.userId}/${widget.friendId}/$messageText',
        ),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        _showSnackBar('Nem sikerült elküldeni az üzenetet: ${response.body}');
        setState(() {
          _messages.remove(optimisticMessage);
        });
      }
    } catch (e) {
      _showSnackBar('Hiba: $e');
      setState(() {
        _messages.remove(optimisticMessage);
      });
    }
  }

  // Üzenetlista görgetése az aljára
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

  // Hibaüzenet megjelenítése SnackBar-ban
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _channel.sink.close(status.goingAway);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friendName),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMessages,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(child: Text('Még nincsenek üzenetek'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(8.0),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == widget.userId;

                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 4.0),
                              padding: EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: isMe ? Colors.blue : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    message.message,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: isMe
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
                      hintText: 'Írj üzenetet...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
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

void main() {
  runApp(MaterialApp(
    title: 'Real-time Chat App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: Chat(
      userId: '123',
      friendId: '456',
      friendName: 'János',
    ),
  ));
}
