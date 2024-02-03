import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Config/AppConfig.dart';
import '../Conversation/ConversationView.dart';
import '../Models/Zone.dart';

Color customWhite = Color(0xFFCDD0CF); // Цвет белого
Color color1 = Color(0xFF282828); // Цвет полученных сообщений


class ZoneCell extends StatefulWidget {
  final Zone zone;

  ZoneCell({required this.zone});

  @override
  _ZoneCellState createState() => _ZoneCellState();
}

class _ZoneCellState extends State<ZoneCell> {

  Widget _buildZoneDescriptionWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            widget.zone.zoneDescription, // Используйте данные из объекта Zone
            style: TextStyle(
              fontSize: 16,
              color: customWhite,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationView(zone: widget.zone),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 220,
        margin: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Заливка для текста
              // Изображение
              CachedNetworkImage(
                imageUrl: "${AppConfig.apiUrl}/${widget.zone.avatar}",
                fit: BoxFit.cover,
                width: double.infinity,
                height: 220,
              ),
              Container(
                width: double.infinity,
                height: 220,
                color: Colors.black.withOpacity(0.5), // Прозрачный черный цвет
              ),

              Positioned(
                top: 10, // Расположить виджет в верхней части
                left: 10,
                child: Row(
                  children: widget.zone.selectedTags.map((tag) {
                    return Row(
                      children: [
                        Text(
                          '#',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: customWhite,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(right: 5), // Маржа между тегами
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: customWhite,
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // Текстовый контент
              Positioned(
                bottom: 0, // Разместить контент внизу
                left: 10,
                right: 10,
                child: Container(
                  padding: EdgeInsets.all(8.0), // Уменьшенный внутренний отступ
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Текст "Обсуждение космоса"
                      Text(
                        widget.zone.zoneTitle,
                        // Используйте данные из объекта Zone
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: customWhite,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Текст "Данная зона будет посвящена обсуждению космоса и всей этой космической тусовке"
                      // Кнопка со стрелкой
                      if (widget.zone.zoneDescription.isNotEmpty)
                        _buildZoneDescriptionWidget(),
                    ],
                  ),
                ),
              ),

              // Позиционирование кнопки в правый нижний угол
              Positioned(
                bottom: 8, // Расстояние от нижнего края контейнера
                right: 8, // Расстояние от правого края контейнера
                child: IconButton(
                  icon: Icon(
                    FontAwesomeIcons.circleArrowRight,
                    size: 20,
                  ),
                  color: customWhite,
                  onPressed: () {
                    // Действие при нажатии на кнопку со стрелкой
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}