import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Szükséges az HttpClient-hez
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  int _lastMessageId = 0;
  HttpClient? _httpClient;
  StreamSubscription<String>? _sseSubscription;

  @override
  void initState() {
    super.initState();
    _loadMessages().then((_) {
      if (_messages.isNotEmpty) {
        _lastMessageId = int.tryParse(_messages.last.id) ?? 0;
      }
      _connectSSE();
    });
  }

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
        // JSON dekódolása, amely vagy List vagy Map lehet
        final dynamic decodedData = jsonDecode(response.body);
        List<dynamic> dataList = [];

        if (decodedData is List) {
          dataList = decodedData;
        } else if (decodedData is Map) {
          // Alapértelmezett kulcs itt "data", de ha az API más kulcsot ad (pl. "messages"), azt használd!
          if (decodedData.containsKey('data')) {
            dataList = decodedData['data'];
          } else if (decodedData.containsKey('messages')) {
            dataList = decodedData['messages'];
          } else {
            throw Exception(
                "A válasz nem tartalmaz 'data' vagy 'messages' kulcsot!");
          }
        } else {
          throw Exception("Ismeretlen JSON struktúra!");
        }

        setState(() {
          _messages = dataList
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

  void _connectSSE() async {
    _httpClient = HttpClient();
    var uri = Uri.parse(
        'https://kovacscsabi.moriczcloud.hu/stream-chat/${widget.friendId}/$_lastMessageId');
    try {
      var request = await _httpClient!.getUrl(uri);
      request.headers.set(HttpHeaders.acceptHeader, "text/event-stream");
      var response = await request.close();

      _sseSubscription = response
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen((line) {
        if (line.startsWith("data:")) {
          final dataStr = line.substring(5).trim();
          try {
            final data = jsonDecode(dataStr);
            final newMessage = ChatMessage.fromJson(data);
            final msgId = int.tryParse(newMessage.id) ?? _lastMessageId;
            if (msgId > _lastMessageId) {
              _lastMessageId = msgId;
              setState(() {
                _messages.add(newMessage);
                _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
              });
              _scrollToBottom();
            }
          } catch (e) {
            print("Hiba az SSE adat feldolgozásában: $e");
          }
        }
      });
    } catch (e) {
      print("SSE kapcsolódási hiba: $e");
    }
  }

  void _sendMessage() async {
    String token = await _getToken();

    if (_messageController.text.trim().isEmpty) {
      _showSnackBar('Nem küldhetsz üres üzenetet!');
      return;
    }
    final messageText = _messageController.text.trim();
    _messageController.clear();
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
            'https://kovacscsabi.moriczcloud.hu/api/postchat/${widget.userId}/${widget.friendId}/$messageText'),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _httpClient?.close(force: true);
    _sseSubscription?.cancel();
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
