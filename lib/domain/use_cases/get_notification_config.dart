import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';

final class GetNotificationConfig {
  const GetNotificationConfig(this._repository);

  final NotificationConfigRepository _repository;

  NotificationConfigModel? call(String habitId) => _repository.get(habitId);
}
