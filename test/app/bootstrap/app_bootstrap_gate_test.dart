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
  });
}
