import 'package:flutter/material.dart';
import 'package:teen/Authentification/RegistrationView.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';



Color backgroundColor = Colors.black; // Цвет фона
Color customWhite = Colors.white; // Цвет белого
Color customGreen = Color(0xFF7ED957); // Зеленый цвет
Color disabledColor = Color(0x807ED957);

class RegistrationNumberView extends StatefulWidget {
  @override
  _RegistrationNumberViewState createState() => _RegistrationNumberViewState();
}

class _RegistrationNumberViewState extends State<RegistrationNumberView> {
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  List<TextEditingController> codeControllers =
  List.generate(6, (index) => TextEditingController());
  List<FocusNode> codeFocusNodes = List.generate(6, (index) => FocusNode());
  int currentCodeIndex = 0;
  bool isButtonEnabled = false;
  bool isExtraInputVisible = false;
  bool isPasswordFieldVisible = false;
  bool isPasswordVisible = false;
  String mail = '';
  bool shouldShake = false;
  bool isError = false;
  bool isCodeCorrect = false;
  bool isLoading = false;
  bool showError = false; // Add state to control error message visibility
  String generatedPassword = '';

  // Добавленные переменные для управления таймером
  bool showTimerText = false;
  bool isTimerClickable = false;
  int timerSeconds = 60;
  bool timerExpired = false;
  Timer? currentTimer;


  @override
  void initState() {
    super.initState();
    startTimer(); // Начните таймер при инициализации
  }

  @override
  void dispose() {
    mailController.dispose();
    codeControllers.forEach((controller) => controller.dispose());
    super.dispose();
  }

  // Метод для сохранения токена
  void _saveToken(String token) {
    // Сохраните токен в хранилище (например, SharedPreferences)
    // В этом примере предполагается, что вы используете пакет shared_preferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('authToken', token);
    });
  }


  Future<void> loginUser(BuildContext context) async {
    setState(() {
      isLoading = true;
      showError = false;
    });

    String mail = mailController.text;
    String password = passwordController.text;

    final response = await http.post(
      Uri.parse('http://192.168.0.14:3000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'mail':  mail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final token = json.decode(response.body)['token'] as String;


      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      // Вывод всех данных из токена
      decodedToken.forEach((key, value) {

      });
      _saveToken(token); // Сохраните токен
      Navigator.pushNamed(context, '/content');
    } else {

      setState(() {
        showError = true;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void checkEmailInDatabase() async {
    var url = Uri.parse('http://192.168.0.14:3000/checkEmail'); // Изменяем URL
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'email': mailController.text}), // Изменяем поле на 'email'
    );

    if (response.statusCode == 200) {
      // Проверка успешна
      showPasswordField();
    } else {
      // Email не найден
      sendConfirmationCode(mailController.text);
      showExtraInput();
    }
  }



  void checkEmailValidity() {
    final emailText = mailController.text;

    // Проверка наличия символа @
    if (emailText.contains('@')) {
      // Разделение строки по символу @
      List<String> parts = emailText.split('@');

      // Проверка, что после @ есть точка и что после точки есть хотя бы два символа
      if (parts.length == 2 && parts[1].contains('.') && parts[1].split('.').last.length >= 2) {
        setState(() {
          isButtonEnabled = true;
          mail = emailText;
        });
        return;
      }
    }
    // Если ввод не соответствует формату электронной почты, отключаем кнопку
    setState(() {
      isButtonEnabled = false;
      mail = '';
    });
  }


  void showPasswordField() {
    setState(() {
      isPasswordFieldVisible = true;
    });
  }


  void showExtraInput() {
    setState(() {
      isExtraInputVisible = true;
      startTimer(); // Запустите таймер при отображении дополнительного ввода
    });
  }

  // Добавленный метод для запуска таймера
  void startTimer() {
    setState(() {
      timerSeconds = 60;
      showTimerText = false;
      isTimerClickable = false;
      timerExpired = false;
    });
    currentTimer?.cancel(); // Отменяем предыдущий таймер
    currentTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timerSeconds > 0) {
        setState(() {
          timerSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          showTimerText = true;
          isTimerClickable = true;
          timerExpired = true;
        });
      }
    });
  }

  void startNewTimer() {
    setState(() {
      timerSeconds = 180;
      showTimerText = false;
      isTimerClickable = false;
      timerExpired = false;
    });
    currentTimer?.cancel(); // Отменяем предыдущий таймер
    currentTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timerSeconds > 0) {
        setState(() {
          timerSeconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          showTimerText = true;
          isTimerClickable = true;
          timerExpired = true;
        });
      }
    });
  }
  bool _isLoginButtonEnabled() {
    final password = passwordController.text;
    return password.length >= 6;

  }

  void onNextButtonPressed() {
    if (!isExtraInputVisible) {
      // Вызовите метод для проверки номера телефона
      if (isPasswordFieldVisible) {
        if (_isLoginButtonEnabled()){
          loginUser(context);
        }
      } else {
        //Потом включишь
        checkEmailInDatabase();
      }
    } else {
      if (isCodeCorrect) {
        Navigator.pushNamed(context, '/registration');
      }
    }
  }

  // Метод для запроса на отправку кода подтверждения на почту
  Future<void> sendConfirmationCode(String email) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.14:3000/sendConfirmationCode'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'email': email,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      generatedPassword = responseBody['confirmationCode'].toString();      print('Код подтверждения отправлен на почту');
      print('Отправленный код: $generatedPassword');
    } else {
      print('Ошибка при отправке кода подтверждения');
      throw Exception('Failed to send confirmation code');
    }
  }


  void onCodeTextFieldChanged(String value) {
    final enteredCode = codeControllers.map((controller) => controller.text).join();
    if (enteredCode.length == 6) {
      if (enteredCode == generatedPassword) {
        setState(() {
          isCodeCorrect = true;
        });
        _startCorrectAnimation();
        Future.delayed(Duration(milliseconds: 1000), () {
          // Навигация на вторую страницу после успешной регистрации
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrationView(
                mail: mailController.text
              ),
            ),
          );
        });
      } else {
        setState(() {
          isError = true;
        });
        _startErrorAnimation();
      }
    }

    if (value.length == 1) {
      if (currentCodeIndex < codeControllers.length - 1) {
        FocusScope.of(context).nextFocus();
        currentCodeIndex++;
      }
    } else if (value.isEmpty) {
      if (currentCodeIndex > 0) {
        FocusScope.of(context).previousFocus();
        currentCodeIndex--;
      }
    }
  }

  // Обновленный метод для анимации ошибки
  void _startErrorAnimation() {
    for (int i = 0; i < codeControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        setState(() {
          codeControllers[i].clear();
        });
      });
    }
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        isError = false;
        FocusScope.of(context).requestFocus(codeFocusNodes[0]);
        currentCodeIndex = 0;
      });
    });
  }

  void _startCorrectAnimation() {
    for (int i = 0; i < codeControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        setState(() {
          codeControllers[i].clear();
        });
      });
    }
    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        isCodeCorrect = false;
        FocusScope.of(context).requestFocus(codeFocusNodes[0]);
        currentCodeIndex = 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Spacer(),
            Image.asset('assets/logo.png', width: 200, height: 200),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Text(
                  'Пожалуйста, введите вашу рабочую почту, на него мы отправим вам 6-ти значный код подтверждения',
                  style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            SizedBox(height: 30),
            isExtraInputVisible
                ? Container(
              height: 60,
              child: TextField(
                controller: TextEditingController(text: mail),
                enabled: !isExtraInputVisible, // Делаем поле неактивным
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: customWhite,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            )
                : Container(
              height: 60,
              child: TextField(
                controller: mailController,
                enabled: !isPasswordFieldVisible,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.]')),
                  FilteringTextInputFormatter.deny(RegExp(r'\s')),
                ],
                onChanged: (text) {
                  checkEmailValidity();
                },
                decoration: InputDecoration(
                  filled: true,
                  fillColor: customWhite,
                  hintText: 'Введите адрес почты',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  contentPadding: EdgeInsets.all(12.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: isPasswordFieldVisible ? 60.0 : 0.0, // устанавливает высоту в зависимости от значения isPasswordVisible
              child: isPasswordFieldVisible
                  ? Container(
                height: 60,
                child: TextField(
                  controller: passwordController,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')), // Запретить пробелы
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')), // Разрешить только английские буквы и цифры
                  ],
                  keyboardType: TextInputType.text,
                  onChanged: (text) {
                    // Обработка изменений в поле пароля
                  },
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: customWhite,
                    hintText: 'Пароль (мин 6)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    contentPadding: EdgeInsets.all(12.0),
                  ),
                  obscureText: !isPasswordVisible,
                ),
              )
                  : SizedBox.shrink(),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: isExtraInputVisible ? 60.0 : 0.0,
              child: isExtraInputVisible
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                      (index) => Flexible(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      child: SizedBox(
                        width: 50,
                        height: 50,
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          transform: isCodeCorrect
                              ? Matrix4.translationValues(
                            isCodeCorrect ? 3.0 : 0.0,
                            0.0,
                            0.0,
                          )
                              : (shouldShake
                              ? Matrix4.translationValues(
                            shouldShake ? -3.0 : 0.0,
                            0.0,
                            0.0,
                          )
                              : Matrix4.translationValues(
                              0.0, 0.0, 0.0)),
                          decoration: BoxDecoration(
                            color: isCodeCorrect
                                ? customGreen
                                : (isError ? Colors.red : customWhite),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: TextField(
                              controller: codeControllers[index],
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                onCodeTextFieldChanged(value);
                              },
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: isCodeCorrect
                                    ? customGreen
                                    : (isError ? Colors.red : customWhite),
                                counterText: "",
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              focusNode: codeFocusNodes[index],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
                  : SizedBox.shrink(),
            ),
            AnimatedOpacity( // Animated error message
              duration: Duration(milliseconds: 500),
              opacity: showError ? 1.0 : 0.0,
              child: Text(
                _isLoginButtonEnabled() ? "Неправильные данные" : 'Пароль мин 6 символов',
                style: TextStyle(
                  color: customWhite,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 50),
            Visibility(
              visible: !isExtraInputVisible,
              child: TextButton(
                onPressed: isButtonEnabled ? onNextButtonPressed : null,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Container(
                  width: 220,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isButtonEnabled ? customGreen : disabledColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    isPasswordFieldVisible ? 'Вход' : 'Дальше',
                    style: TextStyle(
                      color: customWhite,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            // Текст "Запросить новый код" с таймером
            Visibility(
              visible: isExtraInputVisible,
              child: Column(
                children: [
                  TextButton(
                    onPressed: isTimerClickable || timerExpired
                        ? () {
                      // Проверяем истек ли таймер или он кликабельный
                      if (timerExpired) {
                        startNewTimer(); // Запускаем новый таймер с 15 секундами
                      } else {
                        // Добавьте код для запроса нового кода здесь
                      }
                    }
                        : null,
                    child: Text(
                      timerExpired
                          ? 'Запросить новый код' // Если таймер истек, показываем только текст
                          : 'Запросить новый код(${timerSeconds.toString().padLeft(2, '0')})',
                      style: TextStyle(
                        color: isTimerClickable ? customGreen : Colors.grey,
                        decoration: isTimerClickable
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
    );
  }
}