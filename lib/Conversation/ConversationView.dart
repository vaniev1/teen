import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:teen/Models/Zone.dart';
import 'ChatBubble.dart';
import 'Message.dart';
import 'ZoneInfo.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

Color backgroundColor = Color(0xFF1A1A1A); // Цвет фона
Color customWhite = Color(0xFFCDD0CF); // Цвет белого
Color color1 = Color(0xFF282828); // Цвет полученных сообщений
Color color2 = Color(0xFF757575); // Цвет отправленных сообщений

class ConversationView extends StatefulWidget {
  final Zone zone;

  ConversationView({required this.zone});

  @override
  _ConversationViewState createState() => _ConversationViewState();
}

class _ConversationViewState extends State<ConversationView> {
  late Future<List<Message>> messagesFuture;
  final TextEditingController _textController = TextEditingController();
  late String currentUserUid;  // Добавлена переменная для хранения UID текущего пользователя


  @override
  void initState() {
    super.initState();
    messagesFuture = getZoneMessages(widget.zone.id);
    getCurrentUserUid();  // Вызываем функцию для получения UID текущего пользователя
  }

  final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss', 'en')
      .format(DateTime.now().toUtc().add(Duration(hours: 3)));

  Future<Map<String, dynamic>> getUserDataFromToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token != null) {
      final decodedToken = Jwt.parseJwt(token);

      // Extract other data from the token
      final id = decodedToken['id'];
      final username = decodedToken['username'];
      final selectedImagePath = decodedToken['selectedImagePath'];

      return {
        'id': id,
        'username': username,
        'selectedImagePath': selectedImagePath,
      };
    }
    return {}; // Return an empty map if token is not available
  }

  Future<void> getCurrentUserUid() async {
    final userData = await getUserDataFromToken();
    setState(() {
      currentUserUid = userData['id'];
    });
  }

  Future<List<Message>> getZoneMessages(String zoneId) async {
    final response = await http.get(
        Uri.parse('http://192.168.0.16:3000/zones/$zoneId/messages'));

    if (response.statusCode == 200) {
      final List<dynamic> messagesJson = jsonDecode(response.body)['messages'];
      return messagesJson.map((messageJson) => Message.fromJson(messageJson))
          .toList();
    } else {
      throw Exception(
          'Не удалось получить сообщения для зоны: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ZoneInfo(zone: widget.zone)),
              );
            },
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: backgroundColor,
              child: AppBar(
                title: Text(widget.zone.zoneTitle),
                centerTitle: true,
                foregroundColor: customWhite,
                backgroundColor: backgroundColor,
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: CachedNetworkImageProvider(
                          "http://192.168.0.16:3000/${widget.zone.avatar}"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Ошибка: ${snapshot.error}');
                } else {
                  final List<Message> messages = snapshot.data ?? [];
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final bool isCurrentUser = messages[index].uid == currentUserUid;

                      return ChatBubble(
                        sender: isCurrentUser ? 'User1' : 'User2',  // Используйте разные метки для отправителя в зависимости от текущего пользователя
                        text: messages[index].message,
                        photo: messages[index].selectedImagePath,
                        username: messages[index].username,
                      );
                    },
                  );

                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Введите ваше сообщение...',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.white),
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      sendMessage(_textController.text);
                      _textController.clear();
                    }
                  },
                  iconSize: 30.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage(String text) async {
    try {
      final userData = await getUserDataFromToken();
      final userId = userData['id'];
      final username = userData['username'];
      final selectedImagePath = userData['selectedImagePath'];

      print('Sending message to zone: ${widget.zone.id}');

      final response = await http.post(
        Uri.parse('http://192.168.0.16:3000/zones/${widget.zone.id}/messages'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'uid': userId,
          'username': username,
          'selectedImagePath': selectedImagePath,
          'message': text,
        }),
      );

      if (response.statusCode == 200) {
        // Успешно отправлено, обновите список сообщений
        setState(() {
          messagesFuture = getZoneMessages(widget.zone.id);
        });
        print('Message sent successfully');
      } else {
        // Ошибка при отправке
        print('Error sending message: ${response.body}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }
}