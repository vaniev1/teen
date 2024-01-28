import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter/services.dart';
import '../ContentView.dart';
import '../Profile/BlockedAccountView.dart';


Color backgroundColor = Colors.black; // Цвет фона
Color customWhite = Colors.white; // Цвет белого
Color customGreen = Color(0xFF7ED957); // Зеленый цвет
Color disabledColor = Color(0x807ED957);



class LoginView extends StatefulWidget {
  final Function? onLogin;

  LoginView({this.onLogin});

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextEditingController mailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;
  bool showError = false;

  void _saveToken(String token) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('authToken', token);
    });
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken');
  }

  void checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');

    if (token != null) {
      Navigator.pushNamed(context, '/content');
    }
  }

  Future<void> loginUser(BuildContext context) async {
    setState(() {
      isLoading = true;
      showError = false;
    });

    String mail = mailController.text;
    String password = passwordController.text;

    final response = await http.post(
      Uri.parse('http://192.168.0.16:3000/login'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        'email': mail,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final token = json.decode(response.body)['token'] as String;

      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      _saveToken(token);
      final id = decodedToken['id'];

      final isBlocked = await checkBlockedStatus(id);

      if (isBlocked) {
        Navigator.pushNamed(context, '/blocked');
        Navigator.replace(
          context,
          oldRoute: ModalRoute.of(context)!,
          newRoute: MaterialPageRoute(
            builder: (context) => BlockedAccountView(),
          ),
        );
      } else {
        Navigator.pushNamed(context, '/content');
      }
    } else {
      setState(() {
        showError = true;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<bool> checkBlockedStatus(String id) async {
    final response = await http.get(Uri.parse('http://192.168.0.16:3000/checkBlockedStatus/$id'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data['blocked'];
    } else {
      throw Exception('Failed to load user status');
    }
  }

  bool _isLoginButtonEnabled() {
    final password = passwordController.text;
    return password.length >= 6;
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
            TextField(
              controller: mailController,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@.]')),
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: customWhite,
                hintText: 'Адрес вашей почты',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ],
              decoration: InputDecoration(
                filled: true,
                fillColor: customWhite,
                hintText: 'Пароль',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                suffixIcon: IconButton(
                  icon: Icon(isPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !isPasswordVisible,
            ),
            SizedBox(height: 20),
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: showError ? 1.0 : 0.0,
              child: Text(
                'Неправильные данные',
                style: TextStyle(
                  color: customWhite,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 50),
            if (isLoading)
              CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(customGreen)),
            TextButton(
              onPressed: _isLoginButtonEnabled() ? () => loginUser(context) : null,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Container(
                width: 220,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: _isLoginButtonEnabled() ? customGreen : disabledColor,
                ),
                alignment: Alignment.center,
                child: Text(
                  'Вход',
                  style: TextStyle(
                    color: customWhite,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            Spacer(flex: 2),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/phoneConfirm');
              },
              child: Text(
                'Нет аккаунта? Регистрация',
                style: TextStyle(color: customWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    passwordController.addListener(_updateButtonState);
    mailController.addListener(_updateButtonState);
    _getToken().then((token) {
      if (token != null) {
        Navigator.replace(
          context,
          oldRoute: ModalRoute.of(context)!,
          newRoute: MaterialPageRoute(
            builder: (context) => ContentView(initialIndex: 0), // Replace ContentPage with your desired page
          ),
        );
      }
    });
  }

  void _updateButtonState() {
    setState(() {});
  }

  @override
  void dispose() {
    passwordController.dispose();
    mailController.dispose();
    super.dispose();
  }
}