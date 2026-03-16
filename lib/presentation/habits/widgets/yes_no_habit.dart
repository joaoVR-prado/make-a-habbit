import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_horizontal_divider.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_vertical_divider.dart';

class YesNoHabit extends ConsumerStatefulWidget {
  final HabitModel habit;
  const YesNoHabit({
    super.key,
    required this.habit
  });
  

  @override
  ConsumerState<YesNoHabit> createState() => _YesNoHabit();
}

class _YesNoHabit extends ConsumerState<YesNoHabit> {
  bool? _isConcluded;
  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDateProvider);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ChoiceChip(
              label: Text(
                'INCOMPLETO',
                style: TextTheme.of(context).labelSmall,
              ), 
              selected: _isConcluded == false,
              onSelected: (selected) {
                setState(() {
                  _isConcluded = false;
                });
              },
            ),
            ChoiceChip(
              label: Text(
                'CONCLUÍDO',
                style: TextTheme.of(context).labelSmall,
              ), 
              selected: _isConcluded == true,
              onSelected: (selected) {
                setState(() {
                  _isConcluded = true;
                });
              },
            ),
          ],
        ),
        CommonHorizontalDivider(),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            // Cancelar
            TextButton(
              onPressed: (){
                Navigator.pop(context);
                
              },
              child: Text(
                'CANCELAR',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.dialogTextColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            CommonVerticalDivider(),
            // Concluir
            TextButton(
              onPressed: (){
                if (_isConcluded == null) {
                  return; 
                }

                ref.read(concludedHabitsControllerProvider.notifier).saveOrUpdateConclusion(
                  habitId: widget.habit.id, 
                  date: selectedDate, 
                  value: _isConcluded,
                );

                if (context.mounted){
                  Navigator.pop(context);

                }
              
              },
              child: Text(
                'ACEITAR',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.positiveActionDialogTextColor,
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
            ],
          ),
        ),
        
      ],
    );
  }

}