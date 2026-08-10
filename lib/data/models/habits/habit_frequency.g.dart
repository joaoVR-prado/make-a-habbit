// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_frequency.dart';

class DailyHabitFrequencyAdapter extends TypeAdapter<DailyHabitFrequency> {
  @override
  final typeId = 13;

  @override
  DailyHabitFrequency read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    for (int i = 0; i < numOfFields; i++) {
      reader
        ..readByte()
        ..read();
    }
    return const DailyHabitFrequency();
  }

  @override
  void write(BinaryWriter writer, DailyHabitFrequency obj) {
    writer.writeByte(0);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DailyHabitFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WeeklyHabitFrequencyAdapter extends TypeAdapter<WeeklyHabitFrequency> {
  @override
  final typeId = 14;

  @override
  WeeklyHabitFrequency read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeeklyHabitFrequency((fields[0] as List).cast<int>());
  }

  @override
  void write(BinaryWriter writer, WeeklyHabitFrequency obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.weekdays);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeeklyHabitFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MonthlyHabitFrequencyAdapter extends TypeAdapter<MonthlyHabitFrequency> {
  @override
  final typeId = 15;

  @override
  MonthlyHabitFrequency read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MonthlyHabitFrequency((fields[0] as List).cast<int>());
  }

  @override
  void write(BinaryWriter writer, MonthlyHabitFrequency obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.days);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyHabitFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
