import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/use_cases/get_notification_config.dart';
import 'package:mocktail/mocktail.dart';

class MockNotificationConfigRepository extends Mock
    implements NotificationConfigRepository {}

void main() {
  group('CASO DE USO PARA OBTER CONFIGURAÇÃO DE NOTIFICAÇÃO', () {
    test('Retorna a configuração associada ao hábito.', () {
      final repository = MockNotificationConfigRepository();
      const config = NotificationConfigModel(
        isReminderEnabled: true,
        isStreakEnabled: false,
        customTimeNotification: [],
      );
      when(() => repository.get('habit-id')).thenReturn(config);

      final result = GetNotificationConfig(repository)('habit-id');

      expect(result, same(config));
      verify(() => repository.get('habit-id')).called(1);
    });

    test('Retorna nulo quando o hábito não possui configuração.', () {
      final repository = MockNotificationConfigRepository();
      when(() => repository.get('habit-id')).thenReturn(null);

      final result = GetNotificationConfig(repository)('habit-id');

      expect(result, isNull);
    });
  });
}
