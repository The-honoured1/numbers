import 'package:flutter/material.dart';

class GameModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final Widget? screen;

  GameModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    this.screen,
  });
}
