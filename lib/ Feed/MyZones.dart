import 'package:flutter/material.dart';

Color backgroundColor = Color(0xFF1A1A1A); // Цвет фона

class MyZones extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Обещаем, скоро заработает. А пока можете перейти на вкладку последних зон =>',
                  style: TextStyle(fontSize: 18.0, color: Colors.grey, letterSpacing: 2),
                  textAlign: TextAlign.justify,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
