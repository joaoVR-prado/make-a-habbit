import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  // ID*, Icone*, Nome*, tipoConclusao, goalQuantity, Frequência*, DataInicio*, DataFim, descricao, idNoticacao, notificacaoHorario

  @HiveField(0)
  final String id; // UUID
  
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
  final DateTime startData;

  @HiveField(7)
  final DateTime? endData;

  @HiveField(8)
  final String? description;

  @HiveField(9)
  final int? notificationId;

  @HiveField(10)
  final DateTime? notificationTime;

  HabitModel({
    required this.id,
    required this.iconCode,
    required this.name,
    required this.conclusionType,
    this.goalQuantity,
    required this.frequency,
    required this.startData,
    this.endData,
    this.description,
    this.notificationId,
    this.notificationTime

  });


}