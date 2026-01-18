import 'package:hive_ce/hive.dart';

part 'habit_type.g.dart';

@HiveType(typeId: 1)
enum HabitConclusionType {
  @HiveField(0)
  yesNo,

  @HiveField(1)
  goalQuantity,

}