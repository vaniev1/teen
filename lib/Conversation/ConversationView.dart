import 'package:flutter/material.dart';
import 'package:teen/Models/Zone.dart';
import 'ChatBubble.dart';
import 'Message.dart';
import 'ZoneInfo.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
  final List<Message> messages = [
    Message(sender: 'User1', text: 'Привет, как дела в космосе?', photo: Colors.white),
    Message(sender: 'User2', text: 'Привет! Всё отлично, на Марсе нашли следы воды.', photo: Colors.blue),
    Message(sender: 'User3', text: 'Это замечательные новости! А что насчет черных дыр?', photo: Colors.green),
    Message(sender: 'User4', text: 'Привет! Слышал, что планируют новую космическую экспедицию.', photo: Colors.orange),
    Message(sender: 'User1', text: 'Давайте обсудим возможность жизни вне Земли.', photo: Colors.white),
    Message(sender: 'User2', text: 'Отличная идея! Мне интересно, что думают ученые об этом.', photo: Colors.blue),
    Message(sender: 'User3', text: 'Может быть, они найдут новые экзопланеты!', photo: Colors.green),
    Message(sender: 'User4', text: 'Да, и возможно, даже следы жизни.', photo: Colors.orange),
  ];

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          InkWell(
            onTap: () {
              // Навигация на другую страницу
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ZoneInfo(zone: widget.zone)),
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
                      radius: 20, // Установите радиус в соответствии с вашими требованиями
                      backgroundImage: CachedNetworkImageProvider("http://192.168.0.16:3000/${widget.zone.avatar}"),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(
                  sender: messages[index].sender,
                  text: messages[index].text,
                  photo: messages[index].photo,
                );
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


  void sendMessage(String text) {
    setState(() {
      messages.add(Message(sender: 'User1', text: text, photo: Colors.white));
    });
  }
}
