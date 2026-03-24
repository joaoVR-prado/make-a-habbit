import 'package:flutter/material.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_horizontal_divider.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_icon_container.dart';
import 'package:make_a_habbit/presentation/habits/widgets/goal_qtd_text_field.dart';
import 'package:make_a_habbit/presentation/habits/widgets/yes_no_habit.dart';

class CompleteHabit extends StatelessWidget{
  final HabitModel habit;

  const CompleteHabit({
    required this.habit,
    super.key

  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            trailing: CommonIconContainer(
              habitIcon: HabitIcon.fromCode(habit.iconCode), 
              alpha: 0.5
            ),
            title: Text(
              habit.name,
              style: TextTheme.of(context).titleMedium!.copyWith(
                color: AppColors.dialogTextColor,
                fontWeight: FontWeight.bold
              ),

            ),
            subtitle: Text(
              _getDayFormat(),
              style: TextTheme.of(context).bodySmall!.copyWith(
                fontSize: 10,
                color: AppColors.dialogTextColor,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
          CommonHorizontalDivider(),
          habit.conclusionType == HabitConclusionType.goalQuantity
            ? GoalQtdTextField(habit: habit)
            : YesNoHabit(habit: habit) // Aqui vou criar o dialog de sim ou nao do habito
        ],
      ),

    );
    
  }

  String _getDayFormat(){
    final DateTime now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    return '$day/$month/${now.year}';

  }

}