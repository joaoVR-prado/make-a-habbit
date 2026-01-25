import 'package:hive_ce/hive.dart';
import 'habit_frequency_type.dart';

part 'habit_frequency.g.dart';

@HiveType(typeId: 2)
class HabitFrequency {
  @HiveField(0)
  final HabitFrequencyType type;

  @HiveField(1)
  final List<int>? selectedDays;

  // @HiveField(2)
  // final int? daysInterval;

  // @HiveField(3)
  // final List<int>? daysOfMonth;

  HabitFrequency({
    required this.type,
    this.selectedDays,
    //this.daysInterval,
    //this.daysOfMonth

  });

}
