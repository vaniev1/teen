import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import '../Config/AppConfig.dart';


Color backgroundColor = Color(0xFF1A1A1A); // Цвет фона
Color customWhite = Color(0xFFCDD0CF); // Цвет белого
Color color1 = Color(0xFF282828); // Цвет полученных сообщений


class NewZone extends StatefulWidget {
  @override
  _NewZoneState createState() => _NewZoneState();
}

class _NewZoneState extends State<NewZone> {
  final TextEditingController nameController = TextEditingController();
  final int minCaptionLength = 4;
  String? zoneAvatar;
  Color? selectedColor;
  double circleRadius = 0.0;
  final TextEditingController descriptionController = TextEditingController();
  bool isLoading = false;


  final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss', 'en')
      .format(DateTime.now().toUtc().add(Duration(hours: 3)));

  String formatTimestamp(String timestamp) {
    final parsedTime = DateTime.parse(timestamp).toLocal();
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.format(parsedTime.add(Duration(hours: 3)));
  }


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
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        zoneAvatar = pickedFile.path;
        selectedColor = null; // Сбрасываем выбранный цвет, если выбрана фотография
      });
    } else {
      setState(() {
        // Генерируем изображение из выбранного цвета
        selectedColor = Color(0xFFFFFFFF); // Белый цвет, чтобы не было прозрачности
        zoneAvatar = null; // Сбрасываем выбранную фотографию
      });
    }
  }

  Future<Map<String, dynamic>> getUserDataFromToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    if (token != null) {
      final decodedToken = Jwt.parseJwt(token);

      // Extract other data from the token
      final id = decodedToken['id'];
      final username = decodedToken['username'];
      final firstNameLastName = decodedToken['firstNameLastName'];
      final email = decodedToken['email'];
      final selectedImagePath = decodedToken['selectedImagePath'];

      return {
        'id': id,
        'username': username,
        'firstNameLastName': firstNameLastName,
        'email': email,
        'selectedImagePath': selectedImagePath,
      };
    }
    return {}; // Return an empty map if token is not available
  }


  Future<void> createZone() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('${AppConfig.apiUrl}/zone');

    Map<String, dynamic> userData = await getUserDataFromToken();

    var request = http.MultipartRequest('POST', url);

    if (zoneAvatar != null) {
      // Если выбрана фотография, добавляем ее
      request.files.add(await http.MultipartFile.fromPath('zoneAvatar', zoneAvatar!));
    } else if (selectedColor != null) {
      // Если цвет выбран, конвертируем его в изображение и отправляем
      final colorImageBytes = await colorToImage(selectedColor!);
      request.files.add(http.MultipartFile.fromBytes('zoneAvatar', colorImageBytes, filename: 'color-image.png'));
    } else {
      // Если ни цвет, ни фотография не выбраны, можно добавить значение по умолчанию или пропустить
    }

    request.fields.addAll({
      'uid': userData['id'],
      'fullname': userData['firstNameLastName'],
      'selectedImagePath': userData['selectedImagePath'],
      'timestamp': timestamp,
      'username': userData['username'],
      'zoneTitle': nameController.text,  // Добавляем название зоны
      'zoneDescription': descriptionController.text,  // Добавляем описание зоны
      'selectedTags': selectedTags.join(', '),  // Добавляем выбранные теги
    });

    // Добавьте явно заголовок Content-Type
    request.headers['Content-Type'] = 'multipart/form-data';

    try {
      // Send the FormData with the file to the server
      var response = await request.send();

      if (response.statusCode == 200) {
        // Successfully sent
        Navigator.of(context).pop();
      } else {
        print("Error: ${response.reasonPhrase}");
        // Handle errors
      }
    } catch (error) {
      print("Error: $error");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<List<int>> colorToImage(Color color) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromPoints(Offset(0.0, 0.0), Offset(100.0, 100.0)));
    final paint = Paint()..color = color;
    canvas.drawRect(Rect.fromPoints(Offset(0.0, 0.0), Offset(100.0, 100.0)), paint);

    final picture = recorder.endRecording();
    final img = await picture.toImage(100, 100);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);

    return byteData!.buffer.asUint8List();
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
            Visibility(
              visible: nameController.text.length >= minCaptionLength && selectedTags.length >= 2,
              child: TextButton(
                onPressed: () async {
                  // Ваш код, выполняемый при нажатии на активную кнопку
                  FocusScope.of(context).unfocus();
                  Map<String, dynamic> userData = await getUserDataFromToken();
                  if (userData.isNotEmpty) {
                    createZone();
                  } else {
                    // Обработка случая, когда userData пусто
                  }
                  // Ваш код сохранения данных
                },
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
            )
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
                    color: selectedColor != null ? selectedColor : Colors.transparent,
                    image: zoneAvatar != null
                        ? DecorationImage(
                      image: FileImage(File(zoneAvatar!)),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: (zoneAvatar == null && selectedColor == null)
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
                            color: Colors.transparent,
                            border: zoneAvatar != null
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
                            zoneAvatar = null; // Сбрасываем выбранную фотографию
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
                            zoneAvatar = null; // Сбрасываем выбранную фотографию
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
                      horizontal: 20.0,
                      vertical: 15.0,
                    ),
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
                  inputFormatters: [
                    _FirstCharacterNoSpaceFormatter(),
                  ],
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
                            backgroundColor: selectedTags.contains(tag) ? color1 : backgroundColor,
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


class _FirstCharacterNoSpaceFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty && newValue.text.startsWith(' ')) {
      // Если введен пробел как первый символ, удаляем его
      return TextEditingValue(
        text: newValue.text.trimLeft(),
        selection: TextSelection.collapsed(offset: newValue.text.trimLeft().length),
      );
    }
    return newValue;
  }
}
