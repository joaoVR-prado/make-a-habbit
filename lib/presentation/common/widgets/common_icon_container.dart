import 'package:flutter/material.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';

class CommonIconContainer extends StatelessWidget {
  final HabitIcon habitIcon; //final HabitModel habit;
  final double alpha;
  final double? size;
  final double? padding;
  const CommonIconContainer ({
    super.key,
    required this.habitIcon,
    required this.alpha,
    this.size,
    this.padding
  });

  @override 
  Widget build(BuildContext context){
    return Container(
      padding: EdgeInsets.all(padding ?? 12),
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
          offset: Offset(0.5, 0.5),
        )
      ],
      size: size ?? 38,
    ),
  );

  }

}