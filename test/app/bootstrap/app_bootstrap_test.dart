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

    test('Apaga o armazenamento antes de cancelar as notificações.', () async {
      final calls = <String>[];
      final bootstrap = AppBootstrap(
        initializeStorage: () async {},
        initializeNotifications: () async {},
        resetLocalStorage: () async => calls.add('armazenamento'),
        cancelNotifications: () async => calls.add('notificações'),
      );

      await bootstrap.resetLocalData();

      expect(calls, ['armazenamento', 'notificações']);
    });

    test('Informa a etapa quando os dados não podem ser apagados.', () async {
      var canceledNotifications = false;
      final bootstrap = AppBootstrap(
        initializeStorage: () async {},
        initializeNotifications: () async {},
        resetLocalStorage: () async => throw Exception('arquivo bloqueado'),
        cancelNotifications: () async {
          canceledNotifications = true;
        },
      );

      await expectLater(
        bootstrap.resetLocalData(),
        throwsA(
          isA<AppBootstrapException>()
              .having((error) => error.stage, 'etapa', AppBootstrapStage.reset)
              .having(
                (error) => error.cause.toString(),
                'causa',
                contains('arquivo bloqueado'),
              ),
        ),
      );
      expect(canceledNotifications, isFalse);
    });

    test(
      'Mantém a recuperação concluída quando o cancelamento falha.',
      () async {
        final reportedErrors = <Object>[];
        final bootstrap = AppBootstrap(
          initializeStorage: () async {},
          initializeNotifications: () async {},
          resetLocalStorage: () async {},
          cancelNotifications: () async {
            throw Exception('plugin indisponível');
          },
          reportNonFatalError: (error, stackTrace) {
            reportedErrors.add(error);
          },
        );

        await bootstrap.resetLocalData();

        expect(reportedErrors, hasLength(1));
        expect(
          reportedErrors.single.toString(),
          contains('plugin indisponível'),
        );
      },
    );
  });
}
