import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


Color backgroundColor = Color(0xFF1A1A1A); // Цвет фона
Color customWhite = Color(0xFFCDD0CF); // Цвет белого
Color color1 = Color(0xFF282828); // Цвет полученных сообщений
Color color2 = Color(0xFF757575); // Цвет отправленных сообщений

class ChatBubble extends StatelessWidget {
  final String sender;
  final String text;
  final String photo;
  final String username; // Добавлено поле username

  ChatBubble({
    required this.sender,
    required this.text,
    required this.photo,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: sender == 'User1' ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (sender != 'User1' && photo.isNotEmpty)
            CircleAvatar(
              radius: 20,
              backgroundImage: CachedNetworkImageProvider(
                  "http://192.168.0.16:3000/${photo}"),
            ),
          if (sender != 'User1' && photo.isNotEmpty)
            SizedBox(width: 8.0),
          Flexible(
            child: Container(
              padding: EdgeInsets.all(12.0),
              margin: EdgeInsets.only(
                left: sender == 'User1' ? 70 : 0.0,
                right: sender != 'User1' ? 70 : 0.0,
              ),
              decoration: BoxDecoration(
                color: sender == 'User1' ? color1 : color1,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (sender != 'User1') // Отображаем username только для sender, отличного от 'User1'
                    Text(
                      '$username',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(height: 4.0),
                  Text(
                    '$text',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
