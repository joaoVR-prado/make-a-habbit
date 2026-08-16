import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:make_a_habbit/domain/use_cases/ensure_notification_permission.dart';
import 'package:mocktail/mocktail.dart';

final class _MockNotificationScheduler extends Mock
    implements NotificationScheduler {}

void main() {
  group('CASO DE USO PARA PERMISSÃO DE NOTIFICAÇÕES', () {
    test('Não solicita permissão quando ela já foi concedida.', () async {
      final scheduler = _MockNotificationScheduler();
      when(scheduler.isPermissionGranted).thenAnswer((_) async => true);
      final ensurePermission = EnsureNotificationPermission(
        notificationScheduler: scheduler,
      );

      final isAllowed = await ensurePermission();

      expect(isAllowed, isTrue);
      verifyNever(scheduler.requestPermission);
    });

    test('Solicita permissão quando ela ainda não foi concedida.', () async {
      final scheduler = _MockNotificationScheduler();
      when(scheduler.isPermissionGranted).thenAnswer((_) async => false);
      when(scheduler.requestPermission).thenAnswer((_) async => true);
      final ensurePermission = EnsureNotificationPermission(
        notificationScheduler: scheduler,
      );

      final isAllowed = await ensurePermission();

      expect(isAllowed, isTrue);
      verify(scheduler.requestPermission).called(1);
    });

    test('Informa quando o usuário recusa a solicitação.', () async {
      final scheduler = _MockNotificationScheduler();
      when(scheduler.isPermissionGranted).thenAnswer((_) async => false);
      when(scheduler.requestPermission).thenAnswer((_) async => false);
      final ensurePermission = EnsureNotificationPermission(
        notificationScheduler: scheduler,
      );

      final isAllowed = await ensurePermission();

      expect(isAllowed, isFalse);
    });
  });
}
