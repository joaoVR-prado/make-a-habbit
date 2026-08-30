import 'dart:ui';

import 'package:flutter/material.dart';

typedef AppErrorReporter = void Function(FlutterErrorDetails details);

abstract final class AppErrorHandler {
  static void install({AppErrorReporter? reporter}) {
    final effectiveReporter = reporter ?? FlutterError.presentError;
    FlutterError.onError = effectiveReporter;
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      effectiveReporter(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'make_a_habbit',
          context: ErrorDescription('executando uma tarefa assíncrona'),
        ),
      );
      return true;
    };
    ErrorWidget.builder = (_) => const AppUnexpectedErrorView();
  }
}

final class AppUnexpectedErrorView extends StatelessWidget {
  const AppUnexpectedErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Color(0xFFF8F8F8),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Não foi possível exibir este conteúdo.',
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    );
  }
}
