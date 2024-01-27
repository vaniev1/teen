import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import ' Feed/FeedView.dart';
import 'Profile/ProfileView.dart';

Color backgroundColor = Color(0xFF1A1A1A); // Цвет фона
Color headerTabBarColor = Color(0xFF282828); // Цвет хедера и таббара
Color unselectedIconColor = Color(0xFF757575); // Цвет невыбранной иконки
Color customWhite = Color(0xFFCDD0CF); // Цвет белого

class ContentView extends StatefulWidget {
  final int initialIndex;

  ContentView({required this.initialIndex});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    FeedView(initialIndex: 0),
    ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: backgroundColor,
        selectedItemColor: customWhite,
        unselectedItemColor: unselectedIconColor,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.newspaper),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}