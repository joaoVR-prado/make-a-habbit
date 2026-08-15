import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';

abstract interface class NotificationConfigRepository {
  NotificationConfigModel? get(String habitId);
  Future<void> save(
    String habitId,
    NotificationConfigModel notification,
  );
  Future<void> delete(String habitId);
  Future<void> clear();
}
