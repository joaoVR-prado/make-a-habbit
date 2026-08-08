import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/theme/app_colors.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';
import 'package:make_a_habbit/data/providers/notification_config_repository_provider.dart';
import 'package:make_a_habbit/data/providers/notification_scheduler_provider.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_horizontal_divider.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_icon_container.dart';
import 'package:make_a_habbit/presentation/common/widgets/common_vertical_divider.dart';
import 'package:make_a_habbit/presentation/habits/views/create_habit_page.dart';
import 'package:make_a_habbit/presentation/habits/widgets/complete_habit.dart';

class EditOrCompleteHabitDialog extends ConsumerWidget {
  const EditOrCompleteHabitDialog({
    super.key,
    required this.habit,
    this.deleteHabit,
  });

  final HabitModel habit;
  final Future<void> Function(WidgetRef ref)? deleteHabit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              habit.name,
              style: Theme.of(context).textTheme.labelLarge!.copyWith(
                color: AppColors.dialogTextColor,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          CommonIconContainer(
            habitIcon: HabitIcon.fromCode(habit.iconCode),
            alpha: 0.5,
          ),
        ],
      ),
      content: Text(
        'Deseja editar ou concluir esse hábito?',
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: AppColors.dialogTextColor,
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
                  onPressed: () async {
                    final repository = ref.read(
                      notificationConfigRepositoryProvider,
                    );
                    final config = repository.get(habit.id);
                    if (context.mounted) {
                      _startHabitEdition(context, ref, config);
                    }
                  },
                  child: Text(
                    'EDITAR',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.dialogTextColor,
                    ),
                  ),
                ),
                const CommonVerticalDivider(),
                TextButton(
                  onPressed: () {
                    showDialog<void>(
                      context: context,
                      builder: (_) => CompleteHabit(habit: habit),
                    );
                  },
                  child: Text(
                    'CONCLUIR',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.positiveActionDialogTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const CommonHorizontalDivider(),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => _DeleteHabitConfirmationDialog(
                      onConfirm: () => _deleteHabit(ref),
                    ),
                  );
                },
                child: Text(
                  'EXCLUIR HÁBITO',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ],
    );
  }

  Future<void> _deleteHabit(WidgetRef ref) async {
    final callback = deleteHabit;
    if (callback != null) {
      await callback(ref);
      return;
    }

    await ref.read(notificationSchedulerProvider).cancelForHabit(habit.id);
    await ref.read(habitControllerProvider.notifier).deleteHabit(habit.id);
  }

  void _startHabitEdition(
    BuildContext context,
    WidgetRef ref,
    NotificationConfigModel? config,
  ) {
    ref.read(draftHabitProvider.notifier).loadForEdit(habit, config);
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreateHabitPage()),
    );
  }
}

class _DeleteHabitConfirmationDialog extends StatefulWidget {
  const _DeleteHabitConfirmationDialog({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  State<_DeleteHabitConfirmationDialog> createState() =>
      _DeleteHabitConfirmationDialogState();
}

class _DeleteHabitConfirmationDialogState
    extends State<_DeleteHabitConfirmationDialog> {
  bool _isDeleting = false;
  String? _errorMessage;

  Future<void> _confirmDeletion() async {
    if (_isDeleting) return;
    setState(() {
      _isDeleting = true;
      _errorMessage = null;
    });

    try {
      await widget.onConfirm();
      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      final successTextStyle = Theme.of(context).textTheme.labelMedium;
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Hábito excluído com sucesso!',
            style: successTextStyle,
          ),
          backgroundColor: AppColors.calendarMainColor,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _errorMessage = 'Não foi possível excluir o hábito. Tente novamente!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deseja realmente excluir esse hábito?',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: AppColors.dialogTextColor,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              key: const Key('delete_habit_error'),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.red,
              ),
            ),
          ],
        ],
      ),
      actionsPadding: EdgeInsets.zero,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton(
              onPressed: _isDeleting ? null : () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: AppColors.dialogTextColor,
                ),
              ),
            ),
            const CommonVerticalDivider(),
            TextButton(
              onPressed: _isDeleting ? null : _confirmDeletion,
              child: _isDeleting
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Confirmar',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color: AppColors.positiveActionDialogTextColor,
                    ),
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
