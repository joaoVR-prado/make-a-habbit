import 'package:flutter/material.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';

class CommonIconContainer extends StatelessWidget {
  final HabitModel habit;
  final double alpha;
  const CommonIconContainer ({
    super.key,
    required this.habit,
    required this.alpha
  });

  @override 
  Widget build(BuildContext context){
    final habitIcon = HabitIcon.fromCode(habit.iconCode);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        backgroundBlendMode: BlendMode.color,
        color: habitIcon.color.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(12),
      ),
    child: Icon(
      habitIcon.iconData,
      color: habitIcon.color,
      shadows: [
        Shadow(
          color: Colors.black,
          offset: Offset(0.5, 0.5), // X and Y offset
          //blurRadius: 4.0
        )
      ],
      size: 38,
    ),
  );

  }

}