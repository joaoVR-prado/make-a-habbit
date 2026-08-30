import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/app/bootstrap/app_bootstrap.dart';

void main() {
  group('INICIALIZAÇÃO DO APLICATIVO', () {
    test('Inicializa o armazenamento antes das notificações.', () async {
      final calls = <String>[];
      final bootstrap = AppBootstrap(
        initializeStorage: () async => calls.add('armazenamento'),
        initializeNotifications: () async => calls.add('notificações'),
      );

      await bootstrap.initialize();

      expect(calls, ['armazenamento', 'notificações']);
    });

    test('Interrompe a inicialização quando o armazenamento falha.', () async {
      var initializedNotifications = false;
      final bootstrap = AppBootstrap(
        initializeStorage: () async => throw Exception('Hive indisponível'),
        initializeNotifications: () async {
          initializedNotifications = true;
        },
      );

      await expectLater(
        bootstrap.initialize(),
        throwsA(
          isA<AppBootstrapException>()
              .having(
                (error) => error.stage,
                'etapa',
                AppBootstrapStage.storage,
              )
              .having(
                (error) => error.cause.toString(),
                'causa',
                contains('Hive indisponível'),
              ),
        ),
      );
      expect(initializedNotifications, isFalse);
    });

    test(
      'Mantém o aplicativo disponível quando a notificação falha.',
      () async {
        final reportedErrors = <Object>[];
        final bootstrap = AppBootstrap(
          initializeStorage: () async {},
          initializeNotifications: () async {
            throw Exception('Plugin indisponível');
          },
          reportNonFatalError: (error, stackTrace) {
            reportedErrors.add(error);
          },
        );

        await bootstrap.initialize();

        expect(reportedErrors, hasLength(1));
        expect(
          reportedErrors.single.toString(),
          contains('Plugin indisponível'),
        );
      },
    );
  });
}
