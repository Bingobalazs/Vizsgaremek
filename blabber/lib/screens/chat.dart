import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String message;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.message,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderId: json['sender_id'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
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
  WebSocketChannel? _channel;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    _channel = WebSocketChannel.connect(
      Uri.parse(//websocket
          'ws://kovacscsabi.moriczcloud.hu/ws?user_id=${widget.userId}&friend_id=${widget.friendId}'),
    );

    _channel!.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['type'] == 'new_message') {
        final newMessage = ChatMessage.fromJson(data['message']);
        setState(() {
          _messages.add(newMessage);
        });
        _scrollToBottom();
      }
    });
  }

  Future<void> _loadMessages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
            'https://kovacscsabi.moriczcloud.hu/getchat/${widget.userId}/${widget.friendId}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _messages = data.map((json) => ChatMessage.fromJson(json)).toList();
          _isLoading = false;
        });

        Timer(Duration(milliseconds: 300), _scrollToBottom);
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hiba történt az üzenetek betöltésekor')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hiba: $e')),
      );
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text;
    _messageController.clear();

    final optimisticMessage = ChatMessage(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      senderId: widget.userId,
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
            'https://kovacscsabi.moriczcloud.hu/postchat/${widget.userId}/${widget.friendId}/${messageText}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'sender_id': widget.userId,
          'receiver_id': widget.friendId,
          'message': messageText,
        }),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        // Hiba esetén értesítjük a felhasználót
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nem sikerült elküldeni az üzenetet')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hiba: $e')),
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _channel?.sink.close();
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

// Példa oldal, amely meghívja a ChatScreen-t a megfelelő paraméterekkel
class PreviousScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kapcsolatok'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chat(
                  userId: '123', // Ez az aktuális felhasználó ID-ja
                  friendId: '456', // A kiválasztott barát ID-ja
                  friendName: 'János', // A barát neve
                ),
              ),
            );
          },
          child: Text('Chat megnyitása'),
        ),
      ),
    );
  }
}

// App indítása
void main() {
  runApp(MaterialApp(
    title: 'Chat App',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: PreviousScreen(),
  ));
}
