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
  bool _isResetting = false;
  String? _resetError;

  @override
  void initState() {
    super.initState();
    _initialization = widget.bootstrap.initialize();
  }

  void _retry() {
    setState(() {
      _resetError = null;
      _initialization = widget.bootstrap.initialize();
    });
  }

  Future<void> _confirmAndReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apagar dados locais?'),
        content: const Text(
          'Todos os hábitos, conclusões e lembretes serão apagados deste '
          'dispositivo. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            key: const Key('cancel_local_data_reset'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('CANCELAR'),
          ),
          FilledButton(
            key: const Key('confirm_local_data_reset'),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('APAGAR'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() {
      _isResetting = true;
      _resetError = null;
    });
    try {
      await widget.bootstrap.resetLocalData();
      if (!mounted) return;
      setState(() {
        _isResetting = false;
        _initialization = widget.bootstrap.initialize();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isResetting = false;
        _resetError =
            'Não foi possível apagar os dados locais. Tente novamente.';
      });
    }
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
            body: _StartupErrorView(
              onRetry: _retry,
              onReset: _confirmAndReset,
              isResetting: _isResetting,
              resetError: _resetError,
            ),
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
  const _StartupErrorView({
    required this.onRetry,
    required this.onReset,
    required this.isResetting,
    required this.resetError,
  });

  final VoidCallback onRetry;
  final Future<void> Function(BuildContext context) onReset;
  final bool isResetting;
  final String? resetError;

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
              'Tente novamente. Se o problema continuar, os dados locais '
              'podem estar corrompidos.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (resetError != null) ...[
              const SizedBox(height: 12),
              Text(
                resetError!,
                key: const Key('local_data_reset_error'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('retry_app_startup'),
              onPressed: isResetting ? null : onRetry,
              child: const Text('TENTAR NOVAMENTE'),
            ),
            const SizedBox(height: 12),
            TextButton(
              key: const Key('reset_local_data'),
              onPressed: isResetting ? null : () => onReset(context),
              child: isResetting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('APAGAR DADOS LOCAIS'),
            ),
          ],
        ),
      ),
    );
  }
}
