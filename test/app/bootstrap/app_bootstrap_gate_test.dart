import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/app/bootstrap/app_bootstrap.dart';
import 'package:make_a_habbit/app/bootstrap/app_bootstrap_gate.dart';

void main() {
  group('TELA DE INICIALIZAÇÃO DO APLICATIVO', () {
    testWidgets('Exibe progresso enquanto os serviços são preparados.', (
      tester,
    ) async {
      final initialization = Completer<void>();
      final bootstrap = AppBootstrap(
        initializeStorage: () => initialization.future,
        initializeNotifications: () async {},
      );

      await tester.pumpWidget(
        AppBootstrapGate(
          bootstrap: bootstrap,
          child: const MaterialApp(home: Text('Aplicativo disponível')),
        ),
      );

      expect(find.byKey(const Key('app_startup_loading')), findsOneWidget);

      initialization.complete();
      await tester.pumpAndSettle();
      expect(find.text('Aplicativo disponível'), findsOneWidget);
    });

    testWidgets('Permite tentar novamente após uma falha de armazenamento.', (
      tester,
    ) async {
      var attempts = 0;
      final bootstrap = AppBootstrap(
        initializeStorage: () async {
          attempts++;
          if (attempts == 1) throw Exception('Falha temporária');
        },
        initializeNotifications: () async {},
      );

      await tester.pumpWidget(
        AppBootstrapGate(
          bootstrap: bootstrap,
          child: const MaterialApp(home: Text('Aplicativo disponível')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Não foi possível abrir seus dados'), findsOneWidget);
      expect(find.byKey(const Key('retry_app_startup')), findsOneWidget);

      await tester.tap(find.byKey(const Key('retry_app_startup')));
      await tester.pumpAndSettle();

      expect(attempts, 2);
      expect(find.text('Aplicativo disponível'), findsOneWidget);
    });

    testWidgets('Só apaga os dados locais depois da confirmação.', (
      tester,
    ) async {
      var initializationAttempts = 0;
      var resetAttempts = 0;
      final bootstrap = AppBootstrap(
        initializeStorage: () async {
          initializationAttempts++;
          if (initializationAttempts == 1) throw Exception('Dados inválidos');
        },
        initializeNotifications: () async {},
        resetLocalStorage: () async => resetAttempts++,
        cancelNotifications: () async {},
      );

      await tester.pumpWidget(
        AppBootstrapGate(
          bootstrap: bootstrap,
          child: const MaterialApp(home: Text('Aplicativo disponível')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reset_local_data')));
      await tester.pumpAndSettle();
      expect(find.text('Apagar dados locais?'), findsOneWidget);
      expect(resetAttempts, 0);

      await tester.tap(find.byKey(const Key('confirm_local_data_reset')));
      await tester.pumpAndSettle();

      expect(resetAttempts, 1);
      expect(initializationAttempts, 2);
      expect(find.text('Aplicativo disponível'), findsOneWidget);
    });

    testWidgets('Preserva os dados quando a recuperação é cancelada.', (
      tester,
    ) async {
      var resetAttempts = 0;
      final bootstrap = AppBootstrap(
        initializeStorage: () async => throw Exception('Dados inválidos'),
        initializeNotifications: () async {},
        resetLocalStorage: () async => resetAttempts++,
        cancelNotifications: () async {},
      );

      await tester.pumpWidget(
        AppBootstrapGate(
          bootstrap: bootstrap,
          child: const MaterialApp(home: Text('Aplicativo disponível')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reset_local_data')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('cancel_local_data_reset')));
      await tester.pumpAndSettle();

      expect(resetAttempts, 0);
      expect(find.text('Não foi possível abrir seus dados'), findsOneWidget);
    });

    testWidgets('Exibe erro quando os dados locais não podem ser apagados.', (
      tester,
    ) async {
      final bootstrap = AppBootstrap(
        initializeStorage: () async => throw Exception('Dados inválidos'),
        initializeNotifications: () async {},
        resetLocalStorage: () async => throw Exception('Arquivo bloqueado'),
        cancelNotifications: () async {},
      );

      await tester.pumpWidget(
        AppBootstrapGate(
          bootstrap: bootstrap,
          child: const MaterialApp(home: Text('Aplicativo disponível')),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('reset_local_data')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirm_local_data_reset')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('local_data_reset_error')), findsOneWidget);
      expect(find.byKey(const Key('reset_local_data')), findsOneWidget);
    });
  });
}
