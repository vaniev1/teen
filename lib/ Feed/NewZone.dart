import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


Color backgroundColor = Color(0xFF1A1A1A); // Цвет фона
Color customWhite = Color(0xFFCDD0CF); // Цвет белого
Color color1 = Color(0xFF282828); // Цвет полученных сообщений


class NewZone extends StatefulWidget {
  @override
  _NewZoneState createState() => _NewZoneState();
}

class _NewZoneState extends State<NewZone> {
  final TextEditingController nameController = TextEditingController();
  final int minCaptionLength = 15;
  String? imagePath;
  Color? selectedColor;
  double circleRadius = 0.0;
  final TextEditingController descriptionController = TextEditingController();


  List<Color> monotoneColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
    Colors.blue,
    Colors.indigo,
    Colors.purple,
  ];

  List<List<Color>> gradientColors = [
    [Colors.red, Colors.orange],
    [Colors.orange, Colors.yellow],
    [Colors.yellow, Colors.green],
    [Colors.green, Colors.blue],
    [Colors.blue, Colors.indigo],
    [Colors.indigo, Colors.purple],
    [Colors.purple, Colors.pink],
  ];

  Future<void> _getImage() async {
    final pickedFile = await ImagePicker().getImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
        selectedColor =
        null; // Сбрасываем выбранный цвет, если выбрана фотография
      });
    }
  }

  List<String> genericTags = [
    'Искусство',
    'Культура',
    'Музыка',
    'Фильмы',
    'Литература',
    'Технологии',
    'Путешествия',
    'Еда',
    'Мода',
    'Здоровье',
    'Образование',
    'Наука',
    'Психология',
    'Дизайн',
    'Фотография',
    'Спорт',
    'Авто',
    'Природа',
    'Экология',
    'Политика',
    'Экономика',
    'Финансы',
    'Игры',
    'Дом и семья',
    'Ремесла',
    'Домашние животные',
    'Дети',
    'Родители',
    'Свадьбы',
    'Туризм',
    'Игрушки',
    'Гаджеты',
    'Виноделие',
    'Религия',
    'Языки',
    'Живопись',
    'Скульптура',
    'История',
    'Архитектура',
    'Астрономия',
    'Военная тематика',
    'Фантастика',
    'Космос',
    'Робототехника',
    'Видеоигры',
    'Мемы',
    'Юмор',
    'Хобби',
    'Маркетинг',
    'Программирование',
    'Блоггинг',
    'Медицина',
  ];


  List<String> selectedTags = [];

  Widget _buildTagChip(String tag) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: InputChip(
        label: Text(tag, style: TextStyle(color: customWhite)), // Измените цвет текста здесь
        backgroundColor: color1, // Измените цвет фона здесь
        deleteIconColor: Colors.red, // Измените цвет иконки удаления здесь
        onDeleted: () {
          setState(() {
            selectedTags.remove(tag);
          });
        },
      ),
    );
  }


  @override
  void initState() {
    super.initState();

    // Устанавливаем случайный цвет из списка monotoneColors при инициализации
    final Random random = Random();
    selectedColor = monotoneColors[random.nextInt(monotoneColors.length)];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: backgroundColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios),
              color: customWhite,
            ),
            TextButton(
              onPressed: nameController.text.length >= minCaptionLength
                  ? () async {
                Navigator.pop(context);
                FocusScope.of(context).unfocus();
                // Ваш код сохранения данных
              }
                  : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: customWhite,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: Text(
                  'Создать',
                  style: TextStyle(color: backgroundColor),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: backgroundColor,
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  if (selectedColor == null) {
                    _getImage();
                  }
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  width: double.infinity,
                  height: 220,
                  margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: selectedColor != null ? selectedColor : Colors.grey,
                    image: imagePath != null
                        ? DecorationImage(
                      image: FileImage(File(imagePath!)),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: (imagePath == null && selectedColor == null)
                      ? Center(
                    child: Icon(
                      Icons.add_a_photo,
                      color: customWhite,
                      size: 50.0,
                    ),
                  )
                      : null,
                ),
              ),
              SizedBox(height: 10.0),
              Container(
                height: 50.0,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: monotoneColors.length + gradientColors.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Круг с иконкой камеры для обновления фотографии
                      return GestureDetector(
                        onTap: () {
                          _getImage();
                        },
                        child: Container(
                          margin: EdgeInsets.all(4.0),
                          width: 60.0,
                          height: 60.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey,
                            border: imagePath != null
                                ? Border.all(color: customWhite, width: 2.0)
                                : null,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add_a_photo,
                              color: customWhite,
                              size: 30.0,
                            ),
                          ),
                        ),
                      );
                    } else if (index <= monotoneColors.length) {
                      // Монотонные цвета
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = monotoneColors[index - 1];
                            imagePath = null; // Сбрасываем выбранную фотографию
                            circleRadius =
                            60.0; // Устанавливаем радиус для анимации
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(4.0),
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: monotoneColors[index - 1],
                            border: selectedColor == monotoneColors[index - 1]
                                ? Border.all(color: customWhite, width: 2.0)
                                : null,
                          ),
                        ),
                      );
                    } else {
                      // Градиентные цвета
                      int gradientIndex = index - monotoneColors.length - 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedColor = gradientColors[gradientIndex][0];
                            imagePath = null; // Сбрасываем выбранную фотографию
                            circleRadius =
                            60.0; // Устанавливаем радиус для анимации
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.all(4.0),
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: Alignment.center,
                              radius: circleRadius / 60.0,
                              colors: gradientColors[gradientIndex],
                            ),
                            border: selectedColor ==
                                gradientColors[gradientIndex][0]
                                ? Border.all(color: customWhite, width: 2.0)
                                : null,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15.0, top: 30.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Название (обязательно)",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: customWhite,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  controller: nameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Название зоны...',
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 15.0),
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
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Описание (необязательно)",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: customWhite,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  controller: descriptionController,
                  style: TextStyle(color: Colors.white),
                  maxLines: 3,
                  // Установка максимального количества строк
                  maxLength: 150,
                  // Установка максимальной длины текста
                  decoration: InputDecoration(
                    hintText: 'Максимум 150 символов',
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 15.0),
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
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15.0),
                alignment: Alignment.centerLeft,
                child: Text(
                  "Теги (мин 2)",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: customWhite,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        "Выбранные теги",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: customWhite,
                        ),
                      ),
                    ),
                    Wrap(
                      children: selectedTags.map((tag) => _buildTagChip(tag)).toList(),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text(
                        "Предложенные теги",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: customWhite,
                        ),
                      ),
                    ),
                    Wrap(
                      children: genericTags.map((tag) {
                        return ElevatedButton(
                          onPressed: () {
                            if (!selectedTags.contains(tag) && selectedTags.length < 3) {
                              setState(() {
                                selectedTags.add(tag);
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            primary: selectedTags.contains(tag) ? color1 : backgroundColor,
                          ),
                          child: Text(tag, style: TextStyle(color: customWhite),),
                        );
                      }).toList(),
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
