import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';
import 'package:make_a_habbit/domain/services/notification_schedule_planner.dart';
import 'package:uuid/uuid.dart';

typedef HabitIdGenerator = String Function();

String _generateHabitId() => const Uuid().v4();

final class DraftHabitMapper {
  const DraftHabitMapper({
    HabitIdGenerator generateId = _generateHabitId,
    NotificationSchedulePlanner notificationPlanner =
        const NotificationSchedulePlanner(),
  }) : _generateId = generateId,
       _notificationPlanner = notificationPlanner;

  final HabitIdGenerator _generateId;
  final NotificationSchedulePlanner _notificationPlanner;

  MappedHabitDraft call(DraftHabitState draft, {required DateTime now}) {
    final category = draft.category;
    final conclusionType = draft.conclusionType;
    final frequencyType = draft.frequencyType;
    final startDate = draft.startDate;
    if (category == null ||
        conclusionType == null ||
        frequencyType == null ||
        startDate == null) {
      throw const DraftHabitValidationException(
        'Preencha todos os campos obrigatórios.',
      );
    }

    final selectedDays = switch (frequencyType) {
      HabitFrequencyType.weekly => draft.weeklyDays,
      HabitFrequencyType.monthly => draft.monthlyDays,
      HabitFrequencyType.daily => null,
    };

    late final HabitFrequency frequency;
    try {
      frequency = HabitFrequency.fromType(
        type: frequencyType,
        selectedDays: selectedDays,
      );
    } on ArgumentError catch (error) {
      throw DraftHabitValidationException(
        error.message?.toString() ?? 'Frequência inválida.',
      );
    }

    final goalQuantity = conclusionType == HabitConclusionType.goalQuantity
        ? int.tryParse(draft.goalQuantity)
        : null;
    final notificationTime = draft.reminderTime == null
        ? null
        : DateTime(
            now.year,
            now.month,
            now.day,
            draft.reminderTime!.hour,
            draft.reminderTime!.minute,
          );
    final id = draft.existingId ?? _generateId();

    late final HabitModel habit;
    try {
      habit = HabitModel(
        id: id,
        iconCode: category.code,
        name: draft.name,
        description: draft.description,
        conclusionType: conclusionType,
        goalQuantity: goalQuantity,
        frequency: frequency,
        startDate: startDate,
        endDate: draft.endDate,
        notificationId: _notificationPlanner.baseIdForHabit(id),
        notificationTime: notificationTime,
      );
    } on ArgumentError catch (error) {
      throw DraftHabitValidationException(
        error.message?.toString() ?? 'Hábito inválido.',
      );
    }

    return MappedHabitDraft(
      habit: habit,
      notification: NotificationConfigModel(
        isReminderEnabled: notificationTime != null,
        isStreakEnabled: draft.isStreakEnabled,
        customTimeNotification: notificationTime == null
            ? const []
            : [notificationTime],
      ),
      isEditing: draft.existingId != null,
    );
  }
}

final class MappedHabitDraft {
  const MappedHabitDraft({
    required this.habit,
    required this.notification,
    required this.isEditing,
  });

  final HabitModel habit;
  final NotificationConfigModel notification;
  final bool isEditing;
}

final class DraftHabitValidationException implements Exception {
  const DraftHabitValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
