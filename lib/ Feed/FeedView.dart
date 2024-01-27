import 'package:flutter/material.dart';
import 'package:teen/%20Feed/LastZones.dart';

import 'MyZones.dart';
import 'NewZone.dart';

Color backgroundColor = Color(0xFF1A1A1A); // Цвет фона
Color customWhite = Color(0xFFCDD0CF); // Цвет белого

class MyZonesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Your widgets for "Мои зоны" tab
         MyZones(),
        ],
      ),
    );
  }
}

class LatestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Your widgets for "Последние" tab
          LastZones(),
        ],
      ),
    );
  }
}

class FeedView extends StatefulWidget {
  final int initialIndex;

  FeedView({required this.initialIndex});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialIndex);
  }

  // Функция для открытия новой страницы с анимацией "fullscreencover"
  void _navigateToNewPage() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => NewZone(), // Замените NewZone() на ваш класс страницы
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 0.5); // Начать с середины высоты экрана
          const end = Offset.zero;
          const curve = Curves.easeInOutQuart;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          // Используем ScaleTransition для эффекта увеличения размера
          var scaleAnimation = Tween(begin: 0.8, end: 1.0).animate(animation);

          return ScaleTransition(
            scale: scaleAnimation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Center(
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: 'Мои зоны'),
              Tab(text: 'Последние'),
            ],
            labelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: customWhite,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: customWhite,
            ),
            indicatorColor: customWhite,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MyZonesWidget(),
          LatestWidget(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToNewPage();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
        backgroundColor: customWhite,
      ),
    );
  }
}