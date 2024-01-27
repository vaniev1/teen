import 'package:flutter/material.dart';

import '../Conversation/ConversationView.dart';

Color customWhite = Color(0xFFCDD0CF); // Цвет белого

class MyZoneCell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationView(),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 220,
        margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          image: DecorationImage(
            image: AssetImage('assets/kosmos.jpg'), // Замените на реальный путь к вашему изображению в ассетах
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.black.withOpacity(0.5), // Прозрачный черный цвет
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(8.0), // Уменьшенный внутренний отступ
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Обсуждение космоса",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: customWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "Данная зона будет посвящена обсуждению космоса и всей этой космической тусовке",
                      style: TextStyle(
                        fontSize: 16,
                        color: customWhite,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
