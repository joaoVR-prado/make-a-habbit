import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/app/providers/use_case_providers.dart';
import 'package:make_a_habbit/controllers/notifications/notification_reconciliation_coordinator.dart';

class NotificationReconciliationScope extends ConsumerStatefulWidget {
  const NotificationReconciliationScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<NotificationReconciliationScope> createState() =>
      _NotificationReconciliationScopeState();
}

class _NotificationReconciliationScopeState
    extends ConsumerState<NotificationReconciliationScope>
    with WidgetsBindingObserver {
  final _coordinator = NotificationReconciliationCoordinator();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestReconciliation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestReconciliation();
    }
  }

  void _requestReconciliation() {
    unawaited(_coordinator.request(_reconcileOnce));
  }

  Future<void> _reconcileOnce() async {
    try {
      final result = await ref.read(reconcileHabitNotificationsProvider)();
      if (result.hasFailures) {
        FlutterError.reportError(
          FlutterErrorDetails(
            exception: StateError(
              'Falha ao reconciliar notificações dos hábitos: '
              '${result.failedHabitIds.join(', ')}.',
            ),
            library: 'make_a_habbit',
            context: ErrorDescription('reconciliando notificações locais'),
          ),
        );
      }
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'make_a_habbit',
          context: ErrorDescription('reconciliando notificações locais'),
        ),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _coordinator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
