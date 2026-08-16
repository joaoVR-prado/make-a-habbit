import 'package:make_a_habbit/domain/services/notification_scheduler.dart';

final class EnsureNotificationPermission {
  const EnsureNotificationPermission({
    required NotificationScheduler notificationScheduler,
  }) : _notificationScheduler = notificationScheduler;

  final NotificationScheduler _notificationScheduler;

  Future<bool> call() async {
    if (await _notificationScheduler.isPermissionGranted()) return true;
    return _notificationScheduler.requestPermission();
  }
}
