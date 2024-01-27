import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Conversation/ConversationView.dart';

Color customWhite = Color(0xFFCDD0CF); // Цвет белого

class ZoneCell extends StatelessWidget {
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
        child: Stack(
          children: [
            // Заливка для текста
            Container(
              width: double.infinity,
              height: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.black.withOpacity(0.5), // Прозрачный черный цвет
              ),
            ),
            // Текстовый контент
            Positioned(
              bottom: 0, // Разместить контент внизу
              left: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(8.0), // Уменьшенный внутренний отступ
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Текст "Обсуждение космоса"
                    Text(
                      "Обсуждение космоса",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: customWhite,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Текст "Данная зона будет посвящена обсуждению космоса и всей этой космической тусовке"
                    // Кнопка со стрелкой
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Данная зона будет посвящена обсуждению космоса и всей этой космической тусовке",
                            style: TextStyle(
                              fontSize: 16,
                              color: customWhite,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.circleArrowRight,
                            size: 20,
                          ),
                          color: customWhite,
                          onPressed: () {
                            // Действие при нажатии на кнопку со стрелкой
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
