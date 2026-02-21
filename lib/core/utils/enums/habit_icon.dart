import 'package:flutter/material.dart';

enum HabitIcon {
  stopIcon(0, Icons.block, Color(0xFFD93636)),
  artIcon(1, Icons.brush, Color(0xFF9933CC)),
  entertainmentIcon(2, Icons.movie_creation, Color(0xFFF249B3)),
  studiesIcon(3, Icons.book, Color(0xFF4080FF)),
  meditationIcon(4, Icons.self_improvement, Color(0xFF4098FF)),
  healthIcon(5, Icons.local_hospital, Color(0xFF29CCCC)),
  workIcon(6, Icons.work, Color(0xFF3157A3)),
  outdoorsIcon(7, Icons.landscape, Color(0xFF2DB32D)),
  homeIcon(8, Icons.house, Color(0xFFD96236)),
  sportsIcon(9, Icons.fitness_center, Color(0xFFFF8C33)),
  financiesIcon(10, Icons.attach_money, Color(0xFF1C8B4D)),
  nutritionsIcon(11, Icons.restaurant, Color(0xFF96CC29)),
  socialIcon(12, Icons.message, Color(0xFFFFD24D)),
  othersIcon(13, Icons.menu, Color(0xFFBD39BF));

  final int code;
  final IconData iconData;
  final Color color;

  const HabitIcon(this.code, this.iconData, this.color);

  static HabitIcon fromCode(int code){
    return HabitIcon.values.firstWhere(
      (e) => e.code == code,
      orElse: () => HabitIcon.othersIcon,
    );

  }


}