import 'package:flutter/material.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_icon_container.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_vertical_divider.dart';
import 'package:make_a_habbit/presentation/habits/widgets/complete_habit.dart';

class EditOrCompleteHabitDialog extends StatelessWidget {
  final HabitModel habit;

  const EditOrCompleteHabitDialog ({
    super.key,
    required this.habit
  });

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      titlePadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              habit.name,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.dialogTextColor
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          CommonIconContainer(habit: habit, alpha: 0.5)
        ],
      ),
      content: Text(
        'Deseja Editar ou Concluir esse hábito?',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: AppColors.dialogTextColor
        ),
      
      ),
      actionsAlignment: MainAxisAlignment.spaceAround,
      actionsPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      actions: [
        // Editar
        TextButton(
          onPressed: (){
            Navigator.pop(context);
            // Edit
          },
          child: Text(
            'EDITAR',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.dialogTextColor
            ),
          ),
        ),
        CommonVerticalDivider(),
        // Concluir
        TextButton(
          onPressed: (){
            showDialog(
              context: context, 
              builder: (BuildContext context) => CompleteHabit(habit: habit)
            );
            // Edit
          },
          child: Text(
            'CONCLUIR',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.positiveActionDialogTextColor
            ),
          ),
        ),
      ],
    );
  }
}