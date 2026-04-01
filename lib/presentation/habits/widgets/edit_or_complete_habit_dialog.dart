import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_horizontal_divider.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_icon_container.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_vertical_divider.dart';
import 'package:make_a_habbit/presentation/habits/views/create_habit_page.dart';
import 'package:make_a_habbit/presentation/habits/widgets/complete_habit.dart';

class EditOrCompleteHabitDialog extends ConsumerWidget {
  final HabitModel habit;

  const EditOrCompleteHabitDialog ({
    super.key,
    required this.habit
  });

  @override
  Widget build(BuildContext context, WidgetRef ref){
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
          CommonIconContainer(
            habitIcon: HabitIcon.fromCode(habit.iconCode), 
            alpha: 0.5
          )
        ],
      ),
      content: Text(
        'Deseja Editar ou Concluir esse hábito?',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: AppColors.dialogTextColor
        ),
      ),
      // actionsAlignment: MainAxisAlignment.spaceAround,
      // actionsPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      actionsPadding: EdgeInsets.zero,
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: (){
                    _startHabitEdition(
                      context, 
                      ref, 
                      habit
                    );
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
            ),
            const CommonHorizontalDivider(),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: (){
                  showDialog(
                    context: context,
                    builder: (BuildContext context){
                      return _buildDeleteConfirmation(context, ref);

                    }
                  );
                }, 
                child: Text(
                  'EXCLUIR HÁBITO',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold
                  ),
                )
              ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        )
        // Editar
        
      ],
    );
  }

  Widget _buildDeleteConfirmation(BuildContext context, WidgetRef ref){
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      content: Text(
        'Deseja Realmente excluir esse hábito?',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: AppColors.dialogTextColor
        ),
      ),
      actionsPadding: EdgeInsets.zero,
      actions: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancelar',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.dialogTextColor
                    ),
                  ),
                ),
                CommonVerticalDivider(),
                // Concluir
                TextButton(
                  onPressed: (){
                    ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
                    Navigator.pop(context); // Sai da modal de confirmacao
                    Navigator.pop(context); // Sai da modal de edicao
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Hábito excluido com sucesso!',
                          style: Theme.of(context).textTheme.labelMedium,
                          
                        ),
                        backgroundColor: AppColors.calendarMainColor,
                        duration: Duration(seconds: 3),
                      ),
                    );

                  },
                  child: Text(
                    'Confirmar',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.positiveActionDialogTextColor
                    ),
                  ),
                ),
              ],
            ),
          ],
        )  // Editar
      ],
    );
  }

  void _startHabitEdition(BuildContext context, WidgetRef ref, HabitModel habit){
    ref.read(draftHabitIdProvider.notifier).state = habit.id;

    ref.read(draftConclusionNameProvider.notifier).state = habit.name;
    ref.read(draftConclusionTypeProvider.notifier).state = habit.conclusionType;
    ref.read(draftConclusionGoalQuantityProvider.notifier).state = habit.goalQuantity?.toString() ?? '';
    ref.read(draftConclusionDescriptionQuantityProvider.notifier).state = habit.description ?? '';
    ref.read(draftCategoryProvider.notifier).state = HabitIcon.fromCode(habit.iconCode);

    ref.read(draftFrequencyTypeProvider.notifier).state = habit.frequency.type;
    if (habit.frequency.type == HabitFrequencyType.weekly) {
      ref.read(draftWeeklyDaysProvider.notifier).state = habit.frequency.selectedDays ?? [];
    } else if (habit.frequency.type == HabitFrequencyType.monthly) {
      ref.read(draftMonthlyDaysProvider.notifier).state = habit.frequency.selectedDays ?? [];
    }

    ref.read(draftStartDateProvider.notifier).state = habit.startDate;
    ref.read(draftEndDateProvider.notifier).state = habit.endDate;

    if (habit.notificationTime != null) {
      ref.read(draftReminderTimeNotificationProvider.notifier).state = TimeOfDay.fromDateTime(habit.notificationTime!);
    } else {
      ref.read(draftReminderTimeNotificationProvider.notifier).state = null;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const CreateHabitPage())

    );

  }
}