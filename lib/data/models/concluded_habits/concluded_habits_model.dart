import 'package:hive_ce/hive.dart';

part 'concluded_habits_model.g.dart';

@HiveType(typeId: 4)
class ConcludedHabitsModel extends HiveObject {
  @HiveField(0)
  final String habitId; //UUID

  @HiveField(1)
  final DateTime conclusionDate;

  @HiveField(2)
  final dynamic conclusionValue;

  @HiveField(3)
  final String? note;

  ConcludedHabitsModel({
    required this.habitId,
    required this.conclusionDate,
    required this.conclusionValue,
    this.note

  }); 

}