// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'completion_value.dart';

class YesNoCompletionValueAdapter extends TypeAdapter<YesNoCompletionValue> {
  @override
  final typeId = 11;

  @override
  YesNoCompletionValue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return YesNoCompletionValue(fields[0] as bool);
  }

  @override
  void write(BinaryWriter writer, YesNoCompletionValue obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is YesNoCompletionValueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class QuantityCompletionValueAdapter
    extends TypeAdapter<QuantityCompletionValue> {
  @override
  final typeId = 12;

  @override
  QuantityCompletionValue read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuantityCompletionValue((fields[0] as num).toInt());
  }

  @override
  void write(BinaryWriter writer, QuantityCompletionValue obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.value);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuantityCompletionValueAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
