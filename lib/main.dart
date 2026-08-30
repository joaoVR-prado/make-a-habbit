import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/app/bootstrap/app_bootstrap.dart';
import 'package:make_a_habbit/app/bootstrap/app_bootstrap_gate.dart';
import 'package:make_a_habbit/app/errors/app_error_handler.dart';
import 'package:make_a_habbit/core/theme/app_theme.dart';
import 'package:make_a_habbit/presentation/home_page/views/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:make_a_habbit/presentation/notifications/notification_reconciliation_scope.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppErrorHandler.install();
  runApp(
    AppBootstrapGate(
      bootstrap: AppBootstrap(),
      child: const ProviderScope(child: MainApp()),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Calendario
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [Locale('pt', 'BR')],

      title: 'Make a Habbit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const NotificationReconciliationScope(child: HomePage()),
    );
  }
}
