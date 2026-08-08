import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/data/services/awesome_notification_scheduler.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';

final notificationSchedulerProvider = Provider<NotificationScheduler>((ref) {
  return AwesomeNotificationScheduler();
});
