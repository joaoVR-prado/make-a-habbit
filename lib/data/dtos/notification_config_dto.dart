import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';

final class NotificationConfigDto {
  const NotificationConfigDto({
    required this.isReminderEnabled,
    required this.isStreakEnabled,
    required this.customTimes,
  });

  factory NotificationConfigDto.fromDomain(NotificationConfigModel config) =>
    NotificationConfigDto(
      isReminderEnabled: config.isReminderEnabled,
      isStreakEnabled: config.isStreakEnabled,
      customTimes: List.unmodifiable(config.customTimeNotification),
    );

  final bool isReminderEnabled;
  final bool isStreakEnabled;
  final List<DateTime> customTimes;

  NotificationConfigModel toDomain() => NotificationConfigModel(
    isReminderEnabled: isReminderEnabled,
    isStreakEnabled: isStreakEnabled,
    customTimeNotification: List.unmodifiable(customTimes),
  );
}

final class NotificationConfigDtoAdapter
    extends TypeAdapter<NotificationConfigDto> {
  @override
  int get typeId => 10;
  @override
  NotificationConfigDto read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, Object?>{
      for (var index = 0; index < count; index++) reader.readByte(): reader.read(),
    };
    return NotificationConfigDto(
      isReminderEnabled: fields[0] as bool,
      isStreakEnabled: fields[1] as bool,
      customTimes: (fields[2] as List).cast<DateTime>(),
    );
  }
  @override
  void write(BinaryWriter writer, NotificationConfigDto obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.isReminderEnabled)
      ..writeByte(1)
      ..write(obj.isStreakEnabled)
      ..writeByte(2)
      ..write(obj.customTimes);
  }
}
