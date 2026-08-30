import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/app/errors/app_error_handler.dart';

void main() {
  group('TRATAMENTO GLOBAL DE ERROS', () {
    late void Function(FlutterErrorDetails details)? previousFlutterHandler;
    late ErrorWidgetBuilder previousErrorWidgetBuilder;
    late ErrorCallback? previousPlatformHandler;

    setUp(() {
      previousFlutterHandler = FlutterError.onError;
      previousErrorWidgetBuilder = ErrorWidget.builder;
      previousPlatformHandler = PlatformDispatcher.instance.onError;
    });

    tearDown(() {
      FlutterError.onError = previousFlutterHandler;
      ErrorWidget.builder = previousErrorWidgetBuilder;
      PlatformDispatcher.instance.onError = previousPlatformHandler;
    });

    test('Reporta erros assíncronos não capturados.', () {
      final reported = <FlutterErrorDetails>[];
      AppErrorHandler.install(reporter: reported.add);

      final handled = PlatformDispatcher.instance.onError!(
        Exception('Falha assíncrona'),
        StackTrace.current,
      );

      expect(handled, isTrue);
      expect(reported, hasLength(1));
      expect(
        reported.single.exception.toString(),
        contains('Falha assíncrona'),
      );
    });

    testWidgets('Substitui a tela técnica por uma mensagem amigável.', (
      tester,
    ) async {
      AppErrorHandler.install(reporter: (_) {});
      final fallback = ErrorWidget.builder(
        FlutterErrorDetails(exception: Exception('Falha de renderização')),
      );

      await tester.pumpWidget(MaterialApp(home: fallback));

      expect(
        find.text('Não foi possível exibir este conteúdo.'),
        findsOneWidget,
      );
      expect(find.textContaining('Falha de renderização'), findsNothing);
    });
  });
}
