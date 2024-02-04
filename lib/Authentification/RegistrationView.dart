import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:ui';
import '../ContentView.dart';
import '../Config/AppConfig.dart';


Color backgroundColor = Colors.black; // Цвет фона
Color customWhite = Colors.white; // Цвет белого
Color customGreen = Color(0xFF7ED957); // Зеленый цвет
Color disabledColor = Color(0x807ED957);

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const CustomCheckbox({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onChanged(!value);
      },
      child: Container(
        height: 24,
        width: 24,
        decoration: BoxDecoration(
          color: value ? customGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: customWhite, width: 2),
        ),
        child: value
            ? Icon(
          Icons.check,
          size: 20.0,
          color: customWhite,
        )
            : null,
      ),
    );
  }
}

class RegistrationView extends StatefulWidget {
  final String mail; // Добавляем поле для номера телефона


  RegistrationView({required this.mail});

  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  final TextEditingController firstNameLastNameController =
  TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? _selectedImagePath;
  bool isChecked = false;
  bool isPasswordHidden = true;
  bool isLoading = false;
  bool showError = false; // Add state to control error message visibility

  void checkUsernameInDatabase() async {
    // Добавьте ваш URL для проверки номера телефона
    var url = Uri.parse('${AppConfig.apiUrl}/checkUsername');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json', // Указать, что данные отправляются в формате JSON
      },
      body: json.encode({'username': usernameController.text}),
    );


    if (response.statusCode == 200) {
      // Проверка успешна
      setState(() {
        showError = true;
      });
    } else {
      // username не найден
      registerUser();
    }
  }


  Future<void> registerUser() async {
    setState(() {
      isLoading = true;
    });

    final url = Uri.parse('${AppConfig.apiUrl}/register');
    try {
      // Use MultipartRequest for uploading files
      var request = http.MultipartRequest('POST', url);
      request.fields.addAll({
        'firstNameLastName': firstNameLastNameController.text,
        'username': usernameController.text,
        'password': passwordController.text,
        'isChecked': isChecked.toString(),
        'email': widget.mail,
      });

      // Add image file to the request
      if (_selectedImagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('selectedImage', _selectedImagePath!));
      }

      // Send the request
      var response = await request.send();

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final decodedData = json.decode(responseData);
        final token = decodedData['token']; // Extract token from the response

        // Save the token in SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);

        //Navigator.pushNamed(context, '/content');

        Navigator.replace(
          context,
          oldRoute: ModalRoute.of(context)!,
          newRoute: MaterialPageRoute(
            builder: (context) => ContentView(initialIndex: 0), // Replace ContentPage with your desired page
          ),
        );

      } else {

        _showErrorMessage("Registration error, please try again later");
      }
    } catch (error) {

      _showErrorMessage("Registration error, please try again later");
    }
  }



  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ошибка"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("ОК"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }



  bool _isNextButtonEnabled() {
    String firstNameLastName = firstNameLastNameController.text.trim(); // Удаляем пробелы в начале и конце
    firstNameLastName = firstNameLastName.replaceAll(RegExp(r'^\s+'), ''); // Удаляем пробелы перед первым словом
    firstNameLastName = firstNameLastName.replaceAll(RegExp(r'\s+'), ' '); // Заменяем все последовательности пробелов между словами на один
    List<String> nameParts = firstNameLastName.split(' ');
    String firstName = nameParts.first;
    String lastName = nameParts.skip(1).join(); // Объединяем все остальные слова без пробелов
    String formattedName = '$firstName $lastName'; // Добавляем пробел между именем и фамилией
    firstNameLastNameController.text = formattedName.trim(); // Удаляем пробелы в начале и конце после форматирования

    final password = passwordController.text;
    final username = usernameController.text.trim(); // Используйте метод trim() для удаления лишних пробелов

    // Проверяем, что пароль и имя пользователя длиннее или равны 6 символам
    // и оба поля не пустые
    if (password.length >= 6 &&
        username.length >= 6 &&
        username.length <= 12 &&
        firstNameLastName.isNotEmpty &&
        isChecked) {
      return _selectedImagePath != null;
    } else {
      return false; // Если условие не выполняется, кнопка будет деактивирована
    }
  }


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Spacer(flex: 2),
            GestureDetector(
              onTap: _pickImage,
              child: _selectedImagePath != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: Image.file(
                  File(_selectedImagePath!),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              )
                  : ClipRRect(
                  child: Column (
                    children: [
                      Icon(
                        FontAwesomeIcons.camera, // Иконка короны (здесь вы можете выбрать другую иконку)
                        color: customGreen, // Цвет иконки
                        size: 60.0, // Размер иконки
                      ),

                      SizedBox(height: 15),
                      Text(
                        'Добавьте фотографию',
                        style: TextStyle(
                            color: customGreen,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  )
              ),
            ),
            SizedBox(height: 30),
            buildTextField('Имя', controller: firstNameLastNameController, capitalize: true, allowSpaces: true),
            SizedBox(height: 20),
            buildTextField('Имя пользователя (мин 6 символов)', controller: usernameController, capitalize: false, allowSpaces: false),
            SizedBox(height: 20),
            buildTextField(
                'Пароль (мин 6 символов)',
                controller: passwordController,
                isPassword: true,
                capitalize: false,
                allowSpaces: false
            ),
            SizedBox(height: 30),
            Row(
              children: [
                SizedBox(width: 80),
                CustomCheckbox(
                  value: isChecked,
                  onChanged: (value) {
                    setState(() {
                      isChecked = value;
                    });
                  },
                ),
                SizedBox(width: 20),
                Text(
                  'Я принимаю',
                  style: TextStyle(
                    color: customWhite,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/privacyView');
                  },
                  child: Text(
                    'политику',
                    style: TextStyle(color: customWhite),
                  ),
                ),
              ],
            ),
            AnimatedOpacity( // Animated error message
              duration: Duration(milliseconds: 500),
              opacity: showError ? 1.0 : 0.0,
              child: Text(
                'Такой username уже занят',
                style: TextStyle(
                  color: customWhite,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 20),
            Stack(
              children: <Widget>[
                ElevatedButton(
                  onPressed: _isNextButtonEnabled()
                      ? () {
                    // Обработка нажатия кнопки "Дальше"
                    checkUsernameInDatabase();
                  }
                      : null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      _isNextButtonEnabled() ? customGreen : disabledColor,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  child: Container(
                    width: 220,
                    height: 60,
                    alignment: Alignment.center,
                    child: Text(
                      'Завершить',
                      style: TextStyle(
                        color: customWhite,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: isLoading
                      ? Container(
                    color: Colors.black.withOpacity(0.5), // Затемненный фон
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(customGreen),
                      ),
                    ),
                  )
                      : Container(), // Пустой контейнер, если загрузка не активна
                ),
              ],
            ),


            Spacer(flex: 3),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              child: Text(
                'Уже есть аккаунт? Вход',
                style: TextStyle(color: customWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(String hint,
      {TextEditingController? controller, bool isPassword = false, bool capitalize = false, bool allowSpaces = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? isPasswordHidden : false,
      textCapitalization: capitalize ? TextCapitalization.words : TextCapitalization.none,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(allowSpaces ? r'[a-zA-Z0-9 ]' : r'[a-zA-Z0-9]')), // Разрешить пробелы, если allowSpaces = true
      ],
      decoration: InputDecoration(
        filled: true,
        fillColor: customWhite,
        hintText: hint,
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            isPasswordHidden ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              isPasswordHidden = !isPasswordHidden;
            });
          },
        )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: customWhite),
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: customWhite),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
  @override
  void initState() {
    super.initState();

    // Добавьте прослушивание изменений в текстовых полях пароля и имени пользователя
    passwordController.addListener(_updateButtonState);
    usernameController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    setState(() {}); // Перерисовываем виджет, чтобы обновить состояние кнопки
  }

  @override
  void dispose() {
    // Убедитесь, что вы освобождаете ресурсы при удалении виджета
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }
}