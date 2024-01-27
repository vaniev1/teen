import 'package:flutter/material.dart';

Color backgroundColor = Color(0xFF1A1A1A); // Цвет фона
Color customWhite = Color(0xFFCDD0CF); // Цвет белого
Color color1 = Color(0xFF282828); // Цвет полученных сообщений
Color color2 = Color(0xFF757575); // Цвет отправленных сообщений

class ChatBubble extends StatelessWidget {
  final String sender;
  final String text;
  final Color photo; // Изменили тип поля на Color

  ChatBubble({required this.sender, required this.text, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: sender == 'User1' ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (sender != 'User1')
            CircleAvatar(
              backgroundColor: photo,
            ),
          if (sender != 'User1')
            SizedBox(width: 8.0),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12.0),
              margin: EdgeInsets.only(
                left: sender == 'User1' ? 50 : 0.0, // Добавлено условие для отступа справа у отправленных сообщений
                right: sender != 'User1' ? 50 : 0.0, // Добавлено условие для отступа слева у полученных сообщений
              ),
              decoration: BoxDecoration(
                color: sender == 'User1' ? color1 : color1, // Добавлено условие для фонового цвета
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                '$text',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}