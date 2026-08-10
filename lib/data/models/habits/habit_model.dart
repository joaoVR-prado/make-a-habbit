import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
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
            'Hábitos do tipo (sim ou não) não podem possuir meta quantitativa.',
          );
        }
        break;
    }
  }

  @HiveField(0)
  final String id;

  @HiveField(1)
  final int iconCode;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final HabitConclusionType conclusionType;

  @HiveField(4)
  final int? goalQuantity;

  @HiveField(5)
  final HabitFrequency frequency;

  @HiveField(6)
  final DateTime startDate;

  @HiveField(7)
  final DateTime? endDate;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final int? notificationId;

  @HiveField(10)
  final DateTime? notificationTime;

  bool isHabitActiveOn(DateTime date) {
    final cleanDate = DateTime(date.year, date.month, date.day);
    final cleanStartDate = DateTime(startDate.year, startDate.month, startDate.day);
    if (cleanDate.isBefore(cleanStartDate)) return false;

    if (endDate != null) {
      final cleanEndDate = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (cleanDate.isAfter(cleanEndDate)) return false;
    }

    return frequency.occursOn(cleanDate);
  }
}
