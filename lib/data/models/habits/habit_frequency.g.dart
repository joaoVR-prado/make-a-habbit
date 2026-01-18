// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_frequency.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HabitFrequencyAdapter extends TypeAdapter<HabitFrequency> {
  @override
  final typeId = 2;

  @override
  HabitFrequency read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HabitFrequency(
      type: fields[0] as HabitFrequencyType,
      daysOfWeek: (fields[1] as List?)?.cast<int>(),
      daysInterval: (fields[2] as num?)?.toInt(),
      daysOfMonth: (fields[3] as List?)?.cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, HabitFrequency obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.daysOfWeek)
      ..writeByte(2)
      ..write(obj.daysInterval)
      ..writeByte(3)
      ..write(obj.daysOfMonth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HabitFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
