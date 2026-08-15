import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';

final class HabitDto {
  const HabitDto({
    required this.id,
    required this.iconCode,
    required this.name,
    required this.conclusionTypeIndex,
    required this.goalQuantity,
    required this.frequencyTypeIndex,
    required this.selectedDays,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.notificationId,
    required this.notificationTime,
  });

  factory HabitDto.fromDomain(HabitModel habit) => HabitDto(
    id: habit.id,
    iconCode: habit.iconCode,
    name: habit.name,
    conclusionTypeIndex: habit.conclusionType.index,
    goalQuantity: habit.goalQuantity,
    frequencyTypeIndex: habit.frequency.type.index,
    selectedDays: List.unmodifiable(habit.frequency.selectedDays),
    startDate: habit.startDate,
    endDate: habit.endDate,
    description: habit.description,
    notificationId: habit.notificationId,
    notificationTime: habit.notificationTime,
  );

  final String id;
  final int iconCode;
  final String name;
  final int conclusionTypeIndex;
  final int? goalQuantity;
  final int frequencyTypeIndex;
  final List<int> selectedDays;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final int? notificationId;
  final DateTime? notificationTime;

  HabitModel toDomain() => HabitModel(
    id: id,
    iconCode: iconCode,
    name: name,
    conclusionType: HabitConclusionType.values[conclusionTypeIndex],
    goalQuantity: goalQuantity,
    frequency: HabitFrequency.fromType(
      type: HabitFrequencyType.values[frequencyTypeIndex],
      selectedDays: selectedDays,
    ),
    startDate: startDate,
    endDate: endDate,
    description: description,
    notificationId: notificationId,
    notificationTime: notificationTime,
  );
}

final class HabitDtoAdapter extends TypeAdapter<HabitDto> {
  @override
  int get typeId => 0;
  @override
  HabitDto read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, Object?>{
      for (var index = 0; index < count; index++) reader.readByte(): reader.read(),
    };
    return HabitDto(
      id: fields[0] as String,
      iconCode: (fields[1] as num).toInt(),
      name: fields[2] as String,
      conclusionTypeIndex: (fields[3] as num).toInt(),
      goalQuantity: (fields[4] as num?)?.toInt(),
      frequencyTypeIndex: (fields[5] as num).toInt(),
      selectedDays: (fields[6] as List).cast<int>(),
      startDate: fields[7] as DateTime,
      endDate: fields[8] as DateTime?,
      description: fields[9] as String?,
      notificationId: (fields[10] as num?)?.toInt(),
      notificationTime: fields[11] as DateTime?,
    );
  }
  @override
  void write(BinaryWriter writer, HabitDto obj) {
    final values = <Object?>[
      obj.id, obj.iconCode, obj.name, obj.conclusionTypeIndex,
      obj.goalQuantity, obj.frequencyTypeIndex, obj.selectedDays,
      obj.startDate, obj.endDate, obj.description, obj.notificationId,
      obj.notificationTime,
    ];
    writer.writeByte(values.length);
    for (var index = 0; index < values.length; index++) {
      writer..writeByte(index)..write(values[index]);
    }
  }
}
