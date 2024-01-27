import 'package:flutter/material.dart';

Color backgroundColor = Color(0xFF1A1A1A);
Color customWhite = Color(0xFFCDD0CF);
Color color1 = Color(0xFF282828); // Цвет полученных сообщений

class ZoneInfo extends StatelessWidget {
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
                  // Фоновый контейнер с изображением из ассетов
                  Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage('assets/kosmos.jpg'),
                        fit: BoxFit.cover,
                      ),
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
              margin: EdgeInsets.only(left: 15.0, top: 15.0), // Отступ слева и сверху
              alignment: Alignment.centerLeft, // Выравнивание текста по левому краю
              child: Text(
                "Обсуждение космоса",
                style: TextStyle(
                  fontSize: 24, // Увеличенный размер текста
                  fontWeight: FontWeight.bold,
                  color: customWhite,
                ),
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
                children: [
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Данная зона будет посвящена обсуждению космоса и всей этой космической тусовке",
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
            // Текст "Создатель"
            Container(
              margin: EdgeInsets.only(left: 15.0, top: 15.0), // Отступ слева и сверху
              alignment: Alignment.centerLeft, // Выравнивание текста по левому краю
              child: Text(
                "Создатель",
                style: TextStyle(
                  fontSize: 24, // Увеличенный размер текста
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
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage('assets/me.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 15),
                  // Имя пользователя
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "vaniev",
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
                "116 участников",
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
                itemCount: 116,
                itemBuilder: (context, index) {
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding: EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: color1,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage('assets/me.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "User $index",
                          style: TextStyle(
                            fontSize: 16,
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
