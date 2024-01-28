import 'package:flutter/material.dart';
import 'package:teen/Models/Zone.dart';
import 'package:cached_network_image/cached_network_image.dart';

Color backgroundColor = Color(0xFF1A1A1A);
Color customWhite = Color(0xFFCDD0CF);
Color color1 = Color(0xFF282828); // Цвет полученных сообщений

class ZoneInfo extends StatefulWidget {
  final Zone zone;

  ZoneInfo({required this.zone});

  @override
  _ZoneInfoState createState() => _ZoneInfoState();
}

class _ZoneInfoState extends State<ZoneInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: backgroundColor,
        foregroundColor: customWhite,
      ),
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Зона с изображением и текстом
            Container(
              width: double.infinity,
              height: 220,
              margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  // Фоновый контейнер с изображением из сети
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: CachedNetworkImage(
                      imageUrl: "http://192.168.0.16:3000/${widget.zone.avatar}",
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 220,
                    ),
                  ),
                  // Заливка для текста
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Текстовый контент
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 15.0, top: 15.0),
              alignment: Alignment.centerLeft,
              child: Text(
                widget.zone.zoneTitle,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: customWhite,
                ),
              ),
            ),

            widget.zone.zoneDescription.isEmpty
                ? Container() // Пустой контейнер, если описание пусто
                : Container(
              width: double.infinity,
              margin: EdgeInsets.all(15.0),
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: color1,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.zone.zoneDescription,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: customWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(left: 15.0, top: 15.0),
              alignment: Alignment.centerLeft,
              child: Text(
                "Создатель",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: customWhite,
                ),
              ),
            ),
            // Форма с фотографией и именем пользователя
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(15.0),
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: color1, // Цвет фона
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // Фотография
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: CircleAvatar(
                      radius: 25, // Установите радиус в соответствии с вашими требованиями
                      backgroundImage: CachedNetworkImageProvider("http://192.168.0.16:3000/${widget.zone.selectedImagePath}"),
                    ),
                  ),
                  SizedBox(width: 15),
                  // Имя пользователя
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.zone.username,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: customWhite,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Список пользователей
            Container(
              margin: EdgeInsets.only(left: 15.0, top: 15.0), // Отступ слева и сверху
              alignment: Alignment.centerLeft, // Выравнивание текста по левому краю
              child: Text(
                "${widget.zone.members.length} участников",
                style: TextStyle(
                  fontSize: 24, // Увеличенный размер текста
                  fontWeight: FontWeight.bold,
                  color: customWhite,
                ),
              ),
            ),
            // Список пользователей
            Container(
              height: 300,
              margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
              child: ListView.builder(
                itemCount: widget.zone.members.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(15.0),
                    decoration: BoxDecoration(
                      color: color1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: CircleAvatar(
                            radius: 25, // Установите радиус в соответствии с вашими требованиями
                            backgroundImage: CachedNetworkImageProvider("http://192.168.0.16:3000/${widget.zone.selectedImagePath}"),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          widget.zone.username,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: customWhite,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(15.0),
              padding: EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: color1, // Цвет фона
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Центрирование по горизонтали
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Выйти",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
