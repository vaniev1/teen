import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color customGreen = Color(0xFF7ED957); // Зеленый цвет

class BlockedAccountView extends StatelessWidget {
  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1D1332),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/logo.png',
                width: 200,
                height: 200,
              ),
            ),
            Center(
              child: Text(
                'Аккаунт заблокирован',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: customGreen,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Ваш аккаунт заблокирован по причине частых жалоб либо за распространение вредного или непристойного контента.',
                  style: TextStyle(fontSize: 18.0, color: Colors.white, letterSpacing: 1.2),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
            SizedBox(height: 100),
            Center(
              child: TextButton(
                onPressed: () => _logout(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Container(
                  width: 220,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: customGreen,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Выход',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}