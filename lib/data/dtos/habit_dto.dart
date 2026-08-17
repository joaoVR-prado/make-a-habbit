import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/data/dtos/persisted_field_reader.dart';

final class HabitDto {
  const HabitDto({
    required this.id,
    required this.iconCode,
    required this.name,
    required this.conclusionTypeName,
    required this.goalQuantity,
    required this.frequencyTypeName,
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
    conclusionTypeName: habit.conclusionType.name,
    goalQuantity: habit.goalQuantity,
    frequencyTypeName: habit.frequency.type.name,
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
  final String conclusionTypeName;
  final int? goalQuantity;
  final String frequencyTypeName;
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
    conclusionType: _enumFromName(
      conclusionTypeName,
      HabitConclusionType.values,
      'conclusionType',
    ),
    goalQuantity: goalQuantity,
    frequency: HabitFrequency.fromType(
      type: _enumFromName(
        frequencyTypeName,
        HabitFrequencyType.values,
        'frequencyType',
      ),
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
      for (var index = 0; index < count; index++)
        reader.readByte(): reader.read(),
    };
    return HabitDto(
      id: readRequiredField<String>(fields, 0, 'habit.id'),
      iconCode: readRequiredIntField(fields, 1, 'habit.iconCode'),
      name: readRequiredField<String>(fields, 2, 'habit.name'),
      conclusionTypeName: _readEnumName(
        fields[3],
        HabitConclusionType.values,
        'conclusionType',
      ),
      goalQuantity: readOptionalIntField(fields, 4, 'habit.goalQuantity'),
      frequencyTypeName: _readEnumName(
        fields[5],
        HabitFrequencyType.values,
        'frequencyType',
      ),
      selectedDays: readRequiredListField<int>(fields, 6, 'habit.selectedDays'),
      startDate: readRequiredField<DateTime>(fields, 7, 'habit.startDate'),
      endDate: readOptionalField<DateTime>(fields, 8, 'habit.endDate'),
      description: readOptionalField<String>(fields, 9, 'habit.description'),
      notificationId: readOptionalIntField(fields, 10, 'habit.notificationId'),
      notificationTime: readOptionalField<DateTime>(
        fields,
        11,
        'habit.notificationTime',
      ),
    );
  }

  @override
  void write(BinaryWriter writer, HabitDto obj) {
    final values = <Object?>[
      obj.id,
      obj.iconCode,
      obj.name,
      obj.conclusionTypeName,
      obj.goalQuantity,
      obj.frequencyTypeName,
      obj.selectedDays,
      obj.startDate,
      obj.endDate,
      obj.description,
      obj.notificationId,
      obj.notificationTime,
    ];
    writer.writeByte(values.length);
    for (var index = 0; index < values.length; index++) {
      writer
        ..writeByte(index)
        ..write(values[index]);
    }
  }
}

T _enumFromName<T extends Enum>(String name, List<T> values, String fieldName) {
  for (final value in values) {
    if (value.name == name) return value;
  }
  throw FormatException(
    'Valor inválido para $fieldName no hábito persistido: $name.',
  );
}

String _readEnumName<T extends Enum>(
  Object? persistedValue,
  List<T> values,
  String fieldName,
) {
  if (persistedValue is String) return persistedValue;
  if (persistedValue is num) {
    final legacyIndex = persistedValue.toInt();
    if (legacyIndex >= 0 && legacyIndex < values.length) {
      return values[legacyIndex].name;
    }
  }
  throw FormatException(
    'Valor inválido para $fieldName no hábito persistido: $persistedValue.',
  );
}
