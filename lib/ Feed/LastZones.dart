import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teen/%20Feed/ZoneCell.dart';

Color customWhite = Color(0xFFCDD0CF);

class LastZones extends StatefulWidget {
  @override
  _LastZonesState createState() => _LastZonesState();
}

class _LastZonesState extends State<LastZones> {
  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 4.0), // Добавить отступ в 8 пикселей между Switch и IconButton
          Row(
            children: [
              SizedBox(width: 25.0), // Добавить горизонтальный отступ
              Switch(
                value: switchValue,
                onChanged: (bool newValue) {
                  setState(() {
                    switchValue = newValue;
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.fire,
                  color: switchValue ? Colors.deepPurple : customWhite,
                ),
                onPressed: () {
                  // Handle button press after input field
                },
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(FontAwesomeIcons.search),
                    hintText: 'Поиск зоны',
                    filled: true,
                    fillColor: customWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(FontAwesomeIcons.sliders, color: customWhite),
                onPressed: () {
                  // Handle button press after input field
                },
              ),
              SizedBox(width: 20.0), // Добавить горизонтальный отступ
            ],
          ),
          SizedBox(height: 8.0), // Добавить отступ в 8 пикселей между Switch и IconButton
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (BuildContext context, int index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                  ),
                  child: ZoneCell(),
                );
              },
            ),
          ),
          // Additional widgets for LastZones content can be added here
        ],
      ),
    );
  }
}
