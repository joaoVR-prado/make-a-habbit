import 'package:hive_ce/hive.dart';

part 'notification_config_model.g.dart';

@HiveType(typeId: 10)
class NotificationConfigModel extends HiveObject {
  @HiveField(0)
  final bool isReminderEnabled;

  @HiveField(1)
  final bool isStreakEnabled;
  
  @HiveField(2)
  final List<DateTime> customTimeNotification;

  NotificationConfigModel({
    required this.isReminderEnabled,
    required this.isStreakEnabled,
    required this.customTimeNotification

  });


}