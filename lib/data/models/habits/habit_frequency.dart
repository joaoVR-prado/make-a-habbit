import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';

part 'habit_frequency.g.dart';

sealed class HabitFrequency {
  const HabitFrequency._();

  factory HabitFrequency.fromType({
    required HabitFrequencyType type,
    List<int>? selectedDays,
  }) {
    return switch (type) {
      HabitFrequencyType.daily => const DailyHabitFrequency(),
      HabitFrequencyType.weekly => WeeklyHabitFrequency(selectedDays ?? const []),
      HabitFrequencyType.monthly => MonthlyHabitFrequency(selectedDays ?? const []),
    };
  }

  HabitFrequencyType get type;
  List<int> get selectedDays;
  bool occursOn(DateTime date);
}

@HiveType(typeId: 13)
final class DailyHabitFrequency extends HabitFrequency {
  const DailyHabitFrequency() : super._();

  @override
  HabitFrequencyType get type => HabitFrequencyType.daily;

  @override
  List<int> get selectedDays => const [];

  @override
  bool occursOn(DateTime date) => true;
}

@HiveType(typeId: 14)
final class WeeklyHabitFrequency extends HabitFrequency {
  WeeklyHabitFrequency(Iterable<int> weekdays)
      : weekdays = _validateDays(weekdays, min: 1, max: 7, label: 'semanais'),
        super._();

  @HiveField(0)
  final List<int> weekdays;

  @override
  HabitFrequencyType get type => HabitFrequencyType.weekly;

  @override
  List<int> get selectedDays => weekdays;

  @override
  bool occursOn(DateTime date) => weekdays.contains(date.weekday);
}

@HiveType(typeId: 15)
final class MonthlyHabitFrequency extends HabitFrequency {
  MonthlyHabitFrequency(Iterable<int> days)
      : days = _validateDays(days, min: 1, max: 32, label: 'mensais'),
        super._();

  static const lastDayOfMonth = 32;

  @HiveField(0)
  final List<int> days;

  @override
  HabitFrequencyType get type => HabitFrequencyType.monthly;

  @override
  List<int> get selectedDays => days;

  @override
  bool occursOn(DateTime date) {
    if (days.contains(date.day)) return true;
    if (!days.contains(lastDayOfMonth)) return false;
    return date.day == DateTime(date.year, date.month + 1, 0).day;
  }
}

List<int> _validateDays(
  Iterable<int> values, {
  required int min,
  required int max,
  required String label,
}) {
  final days = values.toSet().toList()..sort();
  if (days.isEmpty) {
    throw ArgumentError('A frequência deve possuir dias $label.');
  }
  if (days.any((day) => day < min || day > max)) {
    throw ArgumentError.value(values, 'days', 'Existem dias $label inválidos.');
  }
  return List.unmodifiable(days);
}
