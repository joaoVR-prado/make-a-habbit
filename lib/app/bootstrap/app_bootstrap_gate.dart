import 'package:flutter/material.dart';
import 'package:make_a_habbit/app/bootstrap/app_bootstrap.dart';
import 'package:make_a_habbit/core/theme/app_theme.dart';

final class AppBootstrapGate extends StatefulWidget {
  const AppBootstrapGate({
    super.key,
    required this.bootstrap,
    required this.child,
  });

  final AppBootstrap bootstrap;
  final Widget child;

  @override
  State<AppBootstrapGate> createState() => _AppBootstrapGateState();
}

final class _AppBootstrapGateState extends State<AppBootstrapGate> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = widget.bootstrap.initialize();
  }

  void _retry() {
    setState(() {
      _initialization = widget.bootstrap.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _BootstrapMaterialApp(body: _StartupLoadingView());
        }
        if (snapshot.hasError) {
          return _BootstrapMaterialApp(
            body: _StartupErrorView(onRetry: _retry),
          );
        }
        return widget.child;
      },
    );
  }
}

final class _BootstrapMaterialApp extends StatelessWidget {
  const _BootstrapMaterialApp({required this.body});

  final Widget body;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(body: SafeArea(child: body)),
    );
  }
}

final class _StartupLoadingView extends StatelessWidget {
  const _StartupLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(key: Key('app_startup_loading')),
    );
  }
}

final class _StartupErrorView extends StatelessWidget {
  const _StartupErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.storage_rounded, size: 56),
            const SizedBox(height: 20),
            Text(
              'Não foi possível abrir seus dados',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(
              'Verifique o armazenamento do dispositivo e tente novamente.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('retry_app_startup'),
              onPressed: onRetry,
              child: const Text('TENTAR NOVAMENTE'),
            ),
          ],
        ),
      ),
    );
  }
}
