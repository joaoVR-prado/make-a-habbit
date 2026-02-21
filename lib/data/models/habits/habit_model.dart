import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';

part 'habit_model.g.dart';

@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  // ID*, Icone*, Nome*, tipoConclusao, goalQuantity, Frequência*, DataInicio*, DataFim, descricao, idNoticacao, notificacaoHorario

  // Método para verificarmos se um habito deve aparecer ou não na lista da data fornecida
  bool isHabitActiveOn(DateTime date) {

    final cleanDate = DateTime(date.year, date.month, date.day);
    final cleanStartDate = DateTime(startDate.year, startDate.month, startDate.day);

    // Primeiro valido se o habito ja comecou
    if(cleanDate.isBefore(cleanStartDate)) return false;

    // Segundo valido se o habito ja foi concluido
    if(endDate != null){
      final cleanEndDate = DateTime(endDate!.year, endDate!.month, endDate!.day);
      if(cleanDate.isAfter(cleanEndDate)) return false;

    }

    // Pegamos a frequencia e vemos se o hábito deve aparecer hoje
    switch (frequency.type){
      case HabitFrequencyType.daily:
        return true;

      case HabitFrequencyType.weekly:
        return frequency.selectedDays!.contains(cleanDate.weekday);

      case HabitFrequencyType.monthly:
        return frequency.selectedDays!.contains(cleanDate.day);

    }
    
  }

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
  final DateTime startDate;

  @HiveField(7)
  final DateTime? endDate;

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
    required this.startDate,
    this.endDate,
    this.description,
    this.notificationId,
    this.notificationTime

  });


}
