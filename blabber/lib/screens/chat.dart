import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Szükséges az HttpClient-hez
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Üzenetek modellje
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

// Token lekérése SharedPreferencesből
Future<String> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  if (token == null) throw Exception('No token found');
  return token;
}

// Chat képernyő widget
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
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  int _lastMessageId = 0;
  HttpClient? _httpClient;
  StreamSubscription<String>? _sseSubscription;

  @override
  void initState() {
    super.initState();
    // Figyeljük a scroll pozíciót: ha a felhasználó a lista tetejére görget,
    // akkor betöltjük az adatbázisból származó (régi) üzeneteket.
    _scrollController.addListener(_onScroll);
    _fetchMessages(page: 1).then((_) {
      if (_messages.isNotEmpty) {
        // Az első oldal betöltésekor a lista utolsó eleme az API‑ból származó legfrissebb üzenet.
        _lastMessageId = int.tryParse(_messages.last.id) ?? 0;
      }
      // Kezdetben a lista aljára ugrunk, hogy a legfrissebb (API‑ból származó) üzenetek legyenek láthatóak.
      _scrollToBottom();
      _connectSSE();
    });
  }

  // Ha a lista tetejére görgetünk, betöltjük a további régi üzeneteket.
  void _onScroll() {
    if (_scrollController.position.pixels <=
        _scrollController.position.minScrollExtent + 50) {
      if (!_isLoadingMore && _currentPage < _lastPage) {
        _loadMoreMessages();
      }
    }
  }

  // API kérés az üzenetek lekérésére.
  // Most **nem fordítjuk meg** a lekért listát – így az API által visszaadott sorrend jelenik meg.
  // (Tehát, ha az API DESC sorrendben adja vissza, akkor a legújabb üzenet lesz elöl.)
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
        List<dynamic> dataList = decodedData['data'] ?? decodedData['messages'];

        int currentPage = decodedData['current_page'];
        int lastPage = decodedData['last_page'];

        // Az API által visszaadott üzenetek **nem kerülnek megfordításra**
        List<ChatMessage> fetchedMessages = dataList
            .map<ChatMessage>((json) => ChatMessage.fromJson(json))
            .toList();

        setState(() {
          _currentPage = currentPage;
          _lastPage = lastPage;
          if (prepend) {
            // Régebbi üzenetek betöltésekor azokat a lista elejére illesztjük be,
            // majd korrigáljuk a scroll pozíciót.
            double prevScrollHeight =
                _scrollController.position.maxScrollExtent;
            _messages.insertAll(0, fetchedMessages);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              double newScrollHeight =
                  _scrollController.position.maxScrollExtent;
              double scrollOffset = _scrollController.offset +
                  (newScrollHeight - prevScrollHeight);
              _scrollController.jumpTo(scrollOffset);
            });
          } else {
            // Kezdeti betöltéskor lecseréljük a teljes listát az API‑ból származó üzenetekre.
            _messages = fetchedMessages;
          }
        });
      } else {
        _showSnackBar(
            'Hiba történt az üzenetek betöltésekor: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Hiba: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Régebbi üzenetek lekérése (újabb oldal) – azokat a lista tetejére tesszük.
  Future<void> _loadMoreMessages() async {
    if (_currentPage >= _lastPage) return;
    setState(() {
      _isLoadingMore = true;
    });
    int nextPage = _currentPage + 1;
    await _fetchMessages(page: nextPage, prepend: true);
    setState(() {
      _isLoadingMore = false;
    });
  }

  // SSE kapcsolat létrehozása az élő, friss üzenetek fogadásához.
  // Ezeket a friss üzeneteket nem tesszük be a lista tetejére,
  // hanem a lista végéhez fűzzük, így külön szerepelnek az API‑ból betöltött üzenetektől.
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
            setState(() {
              // A friss, újonnan érkező üzenetet a lista végéhez fűzzük.
              _messages.add(newMessage);
            });
            _scrollToBottom();
          } catch (e) {
            print("Hiba az SSE adat feldolgozásában: $e");
          }
        }
      });
    } catch (e) {
      print("SSE kapcsolódási hiba: $e");
    }
  }

  // Üzenetküldés: Az elküldött (optimista) üzenetet szintén a friss adatok részéhez fűzzük (lista végéhez).
  // Most átadjuk a chat üzenetet a request testében JSON formátumban.
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
            'https://kovacscsabi.moriczcloud.hu/api/postchat/${widget.friendId}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'chat': messageText}),
      );
      if (response.statusCode != 201 && response.statusCode != 200) {
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

  // Ugrás a lista legvégére, hogy a friss (új) üzenet mindig látszódjon.
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

  // Hibaüzenet megjelenítése Snackbar segítségével
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _fetchMessages(page: 1);
            },
          ),
        ],
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
                      final isMe = message.senderId == widget.userId;
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
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
                                  color: isMe ? Colors.white70 : Colors.black54,
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
