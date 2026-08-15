class NotificationConfigModel {
  const NotificationConfigModel({
    required this.isReminderEnabled,
    required this.isStreakEnabled,
    required this.customTimeNotification,
  });

  final bool isReminderEnabled;
  final bool isStreakEnabled;
  final List<DateTime> customTimeNotification;
}
