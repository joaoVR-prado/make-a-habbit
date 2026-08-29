import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';

class HabitModel {
  HabitModel({
    required this.id,
    required this.iconCode,
    required String name,
    required this.conclusionType,
    this.goalQuantity,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.description,
    this.notificationId,
    this.notificationTime,
  }) : name = name.trim() {
    if (id.trim().isEmpty) {
      throw ArgumentError.value(id, 'id', 'O identificador é obrigatório.');
    }
    if (this.name.length < 3) {
      throw ArgumentError.value(
        name,
        'name',
        'O nome deve possuir ao menos 3 caracteres.',
      );
    }
    if (endDate != null) {
      final startDay = DateTime(startDate.year, startDate.month, startDate.day);
      final endDay = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (endDay.isBefore(startDay)) {
        throw ArgumentError.value(
          endDate,
          'endDate',
          'A data final não pode anteceder a inicial.',
        );
      }
    }
    switch (conclusionType) {
      case HabitConclusionType.goalQuantity:
        if (goalQuantity == null || goalQuantity! <= 0) {
          throw ArgumentError.value(
            goalQuantity,
            'goalQuantity',
            'Uma meta positiva é obrigatória para hábitos quantitativos.',
          );
        }
        break;
      case HabitConclusionType.yesNo:
        if (goalQuantity != null) {
          throw ArgumentError.value(
            goalQuantity,
            'goalQuantity',
            'Hábitos do tipo sim ou não não podem possuir meta quantitativa.',
          );
        }
        break;
    }
  }

  final String id;
  final int iconCode;
  final String name;
  final HabitConclusionType conclusionType;
  final int? goalQuantity;
  final HabitFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final int? notificationId;
  final DateTime? notificationTime;

  bool isHabitActiveOn(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    if (day.isBefore(start)) return false;
    if (endDate != null) {
      final end = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (day.isAfter(end)) return false;
    }
    return frequency.occursOn(day);
  }
}
