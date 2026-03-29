import 'package:flutter/material.dart';

enum HabitIcon {
  stopIcon(0, Icons.block, Color(0xFFD93636), 'Deixar algo'),
  outdoorsIcon(1, Icons.landscape, Color(0xFF2DB32D), 'Ar Livre'),
  artIcon(2, Icons.brush, Color(0xFF9933CC), 'Arte'),
  homeIcon(3, Icons.house, Color(0xFFD96236), 'Casa'),
  entertainmentIcon(4, Icons.movie_creation, Color(0xFFF249B3), 'Entretenimento'),
  sportsIcon(5, Icons.fitness_center, Color(0xFFFF8C33), 'Esportes'),
  studiesIcon(6, Icons.book, Color(0xFF4080FF), 'Estudos'),
  financiesIcon(7, Icons.attach_money, Color(0xFF1C8B4D), 'Finanças'),
  meditationIcon(8, Icons.self_improvement, Color(0xFF4098FF), 'Meditação'),
  nutritionsIcon(9, Icons.restaurant, Color(0xFF96CC29), 'Nutrição'),
  healthIcon(10, Icons.local_hospital, Color(0xFF29CCCC), 'Saúde'),
  socialIcon(11, Icons.message, Color(0xFFFFD24D), 'Social'),
  workIcon(12, Icons.work, Color(0xFF3157A3), 'Trabalho'),
  othersIcon(13, Icons.menu, Color(0xFFBD39BF), 'Outros');

  final int code;
  final IconData iconData;
  final Color color;
  final String iconLabel;

  const HabitIcon(this.code, this.iconData, this.color, this.iconLabel);

  static HabitIcon fromCode(int code){
    return HabitIcon.values.firstWhere(
      (e) => e.code == code,
      orElse: () => HabitIcon.othersIcon,
    );

  }

}