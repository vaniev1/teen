import 'package:flutter/material.dart';


class Message {
  final String sender;
  final String text;
  final Color photo; // Изменили тип поля на Color

  Message({required this.sender, required this.text, required this.photo});
}