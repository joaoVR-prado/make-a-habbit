import 'package:flutter/material.dart';
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
  bool _isSaving = false;
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
              onPressed: _isSaving ? null : () async {
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
              onPressed: () async {
                if (_isConcluded == null) {
                  return; 
                }

                setState(() => _isSaving = true);
                try {
                  await ref
                    .read(concludedHabitsControllerProvider.notifier)
                    .saveYesNoConclusion(
                      habitId: widget.habit.id,
                      date: selectedDate,
                      completed: _isConcluded!,
                    );
                } catch (_) {
                  if (mounted) setState(() => _isSaving = false);
                  return;
                }

                if (context.mounted){
                  Navigator.pop(context); // Sai da modal de conclusao
                  Navigator.pop(context); // sai da modal de edicao

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
