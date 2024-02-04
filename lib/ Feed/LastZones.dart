import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:teen/%20Feed/ZoneCell.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/Zone.dart';
import '../Config/AppConfig.dart';

Color customWhite = Color(0xFFCDD0CF);
Color customGreen = Color(0xFF7ED957); // Зеленый цвет

class LastZones extends StatefulWidget {
  @override
  _LastZonesState createState() => _LastZonesState();
}

class _LastZonesState extends State<LastZones> {
  @override
  void initState() {
    super.initState();
    fetchZones();
  }

  List<Zone> zones = [];
  bool isLoading = false;

  bool switchValue = false;


  Future<void> refreshData() async {
    await fetchZones();
  }


  Future<void> fetchZones() async {
    if (isLoading) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse('${AppConfig.apiUrl}/zones'));
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        List<Zone> fetchedZones =
            jsonResponse.map((data) => Zone.fromJson(data)).toList();

        fetchedZones.sort((a, b) => b.timestamp.compareTo(a.timestamp));

        setState(() {
          isLoading = false;
          zones = fetchedZones;
        });
      } else {
        throw Exception('Не удалось загрузить желания');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SizedBox(
              height:
                  4.0), // Добавить отступ в 8 пикселей между Switch и IconButton
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
                activeColor: customGreen,
              ),
              IconButton(
                icon: Icon(
                  FontAwesomeIcons.fire,
                  color: switchValue ? customGreen : customWhite,
                ),
                onPressed: () {
                  // Handle button press after input field
                },
              ),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(FontAwesomeIcons.magnifyingGlass),
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
          SizedBox(
              height:
                  8.0), // Добавить отступ в 8 пикселей между Switch и IconButton
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(customGreen),
                    ),
                  )
                : ListView.builder(
                    itemCount: zones.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (zones.isNotEmpty && index < zones.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                          ),
                          child: ZoneCell(zone: zones[index]),
                        );
                      } else {
                        // Верните заглушку или пустой виджет, если условия не выполняются
                        return Container();
                      }
                    },
                  ),
          ),
          // Additional widgets for LastZones content can be added here
        ],
      ),
      onRefresh: () async {
        refreshData();
      },
      color: customGreen,
    );
  }
}
