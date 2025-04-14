import 'dart:async';
import 'dart:convert';
// Mobil platformon a dart:io HttpClient használata, ezért ezt importáljuk.
import 'dart:io' show HttpClient;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Web esetén csak akkor kell importálni a dart:html csomagot.
import 'dart:html' as html;

/// Chat üzenet modellje
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

/// A token SharedPreferences-ből történő lekérése
Future<String> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) throw Exception('No token found');
  return token;
}

/// Chat képernyő – itt végezzük el a getchat, postchat és streamchat hívásokat
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
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isFetchingOlder = false;
  bool _hasMore = true;
  int _currentPage = 1;

  // Saját SSE stream-nél mobilos esetben a dart:io based subscription
  StreamSubscription<String>? _sseSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _initChat();
  }

  /// Elsőként az aktuális (legfrissebb) üzeneteket töltjük be,
  /// majd elindítjuk az SSE kapcsolatot.
  void _initChat() async {
    await _fetchMessages(page: _currentPage, prepend: false);
    _scrollToBottom();
    _subscribeToSSE();
  }

  /// Ha a lista tetejére görgetünk, akkor próbáljuk betölteni a régebbi üzeneteket.
  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 50) {
      if (!_isFetchingOlder && _hasMore) {
        _loadOlderMessages();
      }
    }
  }

  Future<void> _loadOlderMessages() async {
    setState(() {
      _isFetchingOlder = true;
    });
    int nextPage = _currentPage + 1;
    await _fetchMessages(page: nextPage, prepend: true);
    setState(() {
      _isFetchingOlder = false;
    });
  }

  /// Üzenetek lekérése a szerverről (GET /api/getchat/{friendId}?page=X)
  Future<void> _fetchMessages({required int page, bool prepend = false}) async {
    try {
      String token = await _getToken();
      final url = Uri.parse(
          'https://kovacscsabi.moriczcloud.hu/api/getchat/${widget.friendId}?page=$page');
      final response = await http.get(url, headers: {
        'Authorization': 'Bearer $token',
      });
      if (response.statusCode == 200) {
        final dynamic decodedData = jsonDecode(response.body);
        List<dynamic> dataList = decodedData['data'] ?? [];
        List<ChatMessage> fetchedMessages = dataList
            .map<ChatMessage>((json) => ChatMessage.fromJson(json))
            .toList();

        if (fetchedMessages.isEmpty) {
          setState(() {
            _hasMore = false;
          });
        } else {
          setState(() {
            if (prepend) {
              _messages.insertAll(0, fetchedMessages);
              _currentPage = page;
            } else {
              _messages = fetchedMessages;
            }
          });
        }
      } else {
        _showSnackBar('Hiba az üzenetek lekérésekor: ${response.statusCode}');
      }
    } catch (e) {
      _showSnackBar('Hiba az üzenetek lekérésekor: $e');
      print('Fetch error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// SSE előfizetés a streamChat API-hoz.
  /// Mobilos környezetben HttpClient-et használunk, és a kért headerhez hozzáadjuk az
  /// 'Authorization': 'Bearer $token' értéket, míg weben a token a query paraméterben lesz.
  void _subscribeToSSE() async {
    try {
      String token = await _getToken();
      // A legutolsó üzenet ID-ja alapján indítjuk, hogy csak az újak legyenek elküldve.
      String lastMessageId = _messages.isNotEmpty ? _messages.last.id : '0';
      final url =
          'https://kovacscsabi.moriczcloud.hu/api/streamchat/${widget.friendId}?lastMessageId=$lastMessageId';

      if (kIsWeb) {
        // Flutter Web esetén az EventSource nem támogat egyedi header-eket, ezért a token a query paraméterben kerül átadásra.
        final modifiedUrl = '$url&token=$token';
        try {
          final eventSource = html.EventSource(modifiedUrl);
          eventSource.onMessage.listen((html.MessageEvent event) {
            if (event.data.isNotEmpty) {
              try {
                final jsonData = jsonDecode(event.data);
                final ChatMessage newMessage =
                    ChatMessage.fromJson(jsonData);
                // Duplikáció elkerülése
                bool exists = _messages.any((msg) => msg.id == newMessage.id);
                if (!exists) {
                  setState(() {
                    _messages.add(newMessage);
                  });
                  _scrollToBottom();
                }
              } catch (err) {
                print('Hiba SSE web dekódolása: $err');
              }
            }
          }, onError: (error) {
            print('SSE web hiba: $error');
            _scheduleSSEReconnect();
          });
          print('SSE web kapcsolat létrejött.');
        } catch (err) {
          print('SSE web kapcsolat hiba: $err');
          _scheduleSSEReconnect();
        }
      } else {
        // Mobil (iOS/Android) esetén a HttpClient-et használjuk,
        // itt Explicit módon hozzáadjuk az Authorization header-t.
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(url));
        request.headers.add('Authorization', 'Bearer $token');
        final response = await request.close();

        if (response.statusCode != 200) {
          throw Exception('SSE válaszkód: ${response.statusCode}');
        }

        _sseSubscription = response
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .listen(
          (String line) {
            if (line.startsWith('data:')) {
              final jsonStr = line.substring(5).trim();
              if (jsonStr.isNotEmpty) {
                try {
                  final jsonData = jsonDecode(jsonStr);
                  final ChatMessage newMessage =
                      ChatMessage.fromJson(jsonData);
                  bool exists =
                      _messages.any((msg) => msg.id == newMessage.id);
                  if (!exists) {
                    setState(() {
                      _messages.add(newMessage);
                    });
                    _scrollToBottom();
                  }
                } catch (e) {
                  print('Hiba SSE üzenet dekódolásakor (mobil): $e');
                }
              }
            }
          },
          onError: (error) {
            print('SSE hiba (mobil): $error');
            _scheduleSSEReconnect();
          },
          onDone: () {
            print('SSE kapcsolat lezárult (mobil).');
            _scheduleSSEReconnect();
          },
        );
      }
    } catch (e) {
      print('Hiba az SSE kapcsolat létrehozásakor: $e');
      _scheduleSSEReconnect();
    }
  }

  /// Újrakapcsolódás az SSE-hez 5 másodperces késéssel
  void _scheduleSSEReconnect() {
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _subscribeToSSE();
      }
    });
  }

  /// Üzenet küldése (POST /api/postchat/{friendId})
  void _sendMessage() async {
    try {
      String token = await _getToken();
      final messageText = _messageController.text.trim();
      if (messageText.isEmpty) {
        _showSnackBar('Üzenet nem lehet üres!');
        return;
      }
      _messageController.clear();
      // Optimista frissítés: ideiglenesen hozzáadjuk az üzenetet
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

      final url = Uri.parse(
          'https://kovacscsabi.moriczcloud.hu/api/postchat/${widget.friendId}');
      final response = await http.post(url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'chat': messageText}));

      if (response.statusCode != 200 && response.statusCode != 201) {
        _showSnackBar('Hiba az üzenet elküldésekor. (${response.statusCode})');
        setState(() {
          _messages.removeWhere((msg) => msg.id == optimisticMessage.id);
        });
      }
    } catch (e) {
      _showSnackBar('Hiba az üzenet küldésekor: $e');
      print('SendMessage error: $e');
      setState(() {
        _messages.removeWhere((msg) => msg.id.startsWith('temp_'));
      });
    }
  }

  /// Automatikus scrollozás a lista legaljára, ha új üzenet érkezik
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _sseSubscription?.cancel();
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
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      _currentPage = 1;
                      _hasMore = true;
                      await _fetchMessages(page: _currentPage, prepend: false);
                      _scrollToBottom();
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final bool isRightAligned =
                            message.receiverId == widget.friendId;
                        final now = DateTime.now();
                        final bool showDate =
                            message.timestamp.year != now.year ||
                            message.timestamp.month != now.month ||
                            message.timestamp.day != now.day;
                        return Align(
                          alignment: isRightAligned
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.all(12.0),
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
                                const SizedBox(height: 4.0),
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
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Írj egy üzenetet...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  child: const Icon(Icons.send),
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
