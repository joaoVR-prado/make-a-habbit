import 'package:flutter/material.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/core/utils/enums/habit_status.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_icon_container.dart';
import 'package:make_a_habbit/presentation/habits/widgets/edit_or_complete_habit_dialog.dart';

class HabitsListTile extends StatelessWidget {
  final HabitModel habit;
  final HabitStatus habitStatus;
  final VoidCallback onTap;

  const HabitsListTile({
    super.key,
    required this.habit,
    required this.habitStatus,
    required this.onTap

  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadiusGeometry.circular(16)),
      child: InkWell(
        onTap: () {
          showDialog(
            context: context, 
            builder: (BuildContext dialogContext){
              return EditOrCompleteHabitDialog(habit: habit);

            }
          );
        },
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // Parte dos icones dos habitos
          leading: CommonIconContainer(
            habit: habit, 
            alpha: 0.4
          ),
          // Parte do nome e descricao do habito
          title: Text(
            habit.name,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          subtitle: Text(
            habit.description == null ? '' : habit.description!,
            style: Theme.of(context).textTheme.bodySmall,
        
          ),
        
          trailing: _buildStatusIcon(),
        ),
      ),
    );

  }

  Widget _buildStatusIcon(){
    switch (habitStatus){
      case HabitStatus.done:
        return const Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 32,
          key: ValueKey('done'),
        );

      case HabitStatus.incomplete:
        return const Icon(
          Icons.cancel,
          color: Colors.red,
          size: 32,
          key: ValueKey('incomplete'),
        );

      case HabitStatus.pending:
        return const Icon(
          Icons.circle_outlined,
          color: AppColors.pendingStatusIconColor,
          size: 32,
          key: ValueKey('pending'),

        );
        
    }

  }

}