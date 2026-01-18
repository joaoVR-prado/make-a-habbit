import 'package:hive_ce/hive.dart';

part 'habit_frequency_type.g.dart';

@HiveType(typeId: 3)
enum HabitFrequencyType {
  @HiveField(0)
  daily,

  @HiveField(1)
  weekly,

  @HiveField(2)
  monthly,

  @HiveField(3)
  daysInterval,


}