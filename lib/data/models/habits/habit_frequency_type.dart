import 'package:hive_ce/hive.dart';

part 'habit_frequency_type.g.dart';

@HiveType(typeId: 3)
enum HabitFrequencyType {
  @HiveField(0)
  daily, // Todos os dias

  @HiveField(1)
  weekly, // Alguns dias da semana

  @HiveField(2)
  monthly, // Dias especificos do mes

  // @HiveField(3)
  // daysInterval, // X vezes na semana


}