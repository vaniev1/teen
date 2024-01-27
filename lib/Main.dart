import 'package:flutter/material.dart';
//import 'package:vizzie/SplashScreen_view.dart';
//import 'package:vizzie/about_vizzie.dart';
//import 'package:vizzie/blockedAccount_view.dart';
//import 'package:vizzie/privacy_view.dart';
//import 'package:vizzie/registration_number_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
//import 'package:vizzie/safetyMenu_view.dart';
//import 'content_view.dart';
//import 'login_view.dart';
//import 'registration_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decode/jwt_decode.dart';
import 'Authentification/LoginView.dart';
import 'Authentification/RegistrationMailVIew.dart';
import 'Authentification/RegistrationView.dart';
import 'ContentView.dart';
import 'Profile/BlockedAccountView.dart';

Color background = Color(0xFF1D1332);

Future<void> updateLastUse(String id) async {
  try {
    final response = await http.post(
      Uri.parse('http://213.171.12.210:27017/updateLastUse'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'id': id}),
    );

    if (response.statusCode == 200) {

    } else {

    }
  } catch (error) {

    // Handle the error gracefully, for example, show a message to the user
  }
}

Future<bool> checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');

  if (token != null) {

    return true;
  } else {

    return false;
  }
}

Future<bool> checkBlockedStatus(String id) async {
  //Поменяй на прод
  final response = await http.get(Uri.parse('http://213.171.12.210:27017/checkBlockedStatus/$id'));

  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    return data['blocked'];
  } else {
    throw Exception('Failed to load user status');
  }
}

void deleteToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken');

}

void clearSavedPageIndex() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('profilePageIndex');

}



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting("en", null); // Инициализация локали для GMT+3
  final isUserLoggedIn = await checkLoginStatus();
  final id = await getUsernameFromToken();
  runApp(
    MaterialApp(
      title: 'Teen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        splashColor: background,
      ),
      home: FutureBuilder(
        future: checkBlockedStatus(id), // Используйте значение username
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return Container();
              //return BlockedAccountView();
            } else {
              if (isUserLoggedIn) {
                clearSavedPageIndex();  // Удалить сохраненный индекс страницы
                updateLastUse(id);
                return ContentView(initialIndex: 0,);
              } else {
                return LoginView();
              }
            }
          } else {
            return Container();
            //return SplashScreen();
          }
        },
      ),
      routes: {
        '/content': (context) => ContentView(initialIndex: 0,),
        '/registration': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is String) {
            return RegistrationView(mail: args);
          } else {
            return RegistrationNumberView();
          }
        },
        '/blocked': (context) => BlockedAccountView(),
        //'/aboutUs': (context) => AboutVizzieView(),
        //'/privacyView': (context) => PrivacyView(),
        '/phoneConfirm': (context) => RegistrationNumberView(),
        //'/safety': (context) => SafetyMenu(),
        '/login': (context) => LoginView(),
      },
    ),
  );
}

Future<String> getUsernameFromToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('authToken');
  if (token != null) {
    final decodedToken = Jwt.parseJwt(token);
    final id = decodedToken['id'];
    return id;
  }
  return '';
}