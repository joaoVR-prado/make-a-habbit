import 'package:flutter/material.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_icon_container.dart';

class EditOrCompleteHabitDialog extends StatelessWidget {
  final HabitModel habit;

  const EditOrCompleteHabitDialog ({
    super.key,
    required this.habit
  });

  @override
  Widget build(BuildContext context){
    return AlertDialog(
      //contentPadding: EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      titlePadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            habit.name,
            style: Theme.of(context).textTheme.labelLarge!.copyWith(
              color: AppColors.dialogTextColor
            ),
          ),
          CommonIconContainer(habit: habit, alpha: 0.5)
        ],
      ),
      // contentPadding: EdgeInsets.only(
      //   left: 16,
      //   right: 16,
      //   top: 10,
      //   bottom: 26
      // ),
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

        SizedBox(
          height: 40,
          child: VerticalDivider(
            width: 10,
            thickness: 0.5,
            color: Color(0xFF459AC3)
          ),
        ),

        // Concluir
        TextButton(
          onPressed: (){
            Navigator.pop(context);
            // Edit
          },
          child: Text(
            'CONCLUIR',
            style: Theme.of(context).textTheme.titleMedium!.copyWith(
              color: AppColors.positiveActionDialogTextColor
            ),
          ),
        ),
          // TextButton.icon(
          // onPressed: (){
          //   Navigator.pop(context);
          //   // Edit
          // }, 
          // label: Text(
          //   'Concluir',
          //   style: Theme.of(context).textTheme.titleMedium!.copyWith(
          //     color: AppColors.dialogTextColor
          //   ),
          // ),
          // icon: const Icon(
          //   Icons.done,
          //   size: 26,
          //   color: AppColors.completeHabitIcon,

          // ),
       // )

      ],

    );
  }
}