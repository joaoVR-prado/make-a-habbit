import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
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
      actionsAlignment: MainAxisAlignment.spaceAround,
      actionsPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
      actions: [
        // Editar
        TextButton(
          onPressed: (){
            //Navigator.pop(context);
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
    );
  }

  void _startHabitEdition(BuildContext context, WidgetRef ref, HabitModel habit){
    ref.read(draftHabitIdProvider.notifier).state = habit.id;
    print(habit.id);
    
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

    Navigator.pop(context); 

    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreateHabitPage())

    );

  }
}