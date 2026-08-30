import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/notifications/notification_reconciliation_coordinator.dart';

void main() {
  group('COORDENAÇÃO DA RECONCILIAÇÃO DE NOTIFICAÇÕES', () {
    test('Não executa reconciliações simultaneamente.', () async {
      final coordinator = NotificationReconciliationCoordinator();
      final firstExecution = Completer<void>();
      var running = 0;
      var maximumRunning = 0;
      var executions = 0;

      Future<void> reconcile() async {
        executions++;
        running++;
        maximumRunning = running > maximumRunning ? running : maximumRunning;
        if (executions == 1) await firstExecution.future;
        running--;
      }

      final firstRequest = coordinator.request(reconcile);
      await Future<void>.delayed(Duration.zero);
      await coordinator.request(reconcile);

      expect(executions, 1);
      firstExecution.complete();
      await firstRequest;

      expect(executions, 2);
      expect(maximumRunning, 1);
    });

    test('Ignora novas solicitações depois de ser descartado.', () async {
      final coordinator = NotificationReconciliationCoordinator();
      var executions = 0;
      coordinator.dispose();

      await coordinator.request(() async => executions++);

      expect(executions, 0);
    });
  });
}
