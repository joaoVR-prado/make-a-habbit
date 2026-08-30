import 'dart:async';

final class NotificationReconciliationCoordinator {
  bool _isRunning = false;
  bool _isRequested = false;
  bool _isDisposed = false;

  Future<void> request(Future<void> Function() reconciliation) async {
    if (_isDisposed) return;

    _isRequested = true;
    if (_isRunning) return;

    _isRunning = true;
    try {
      while (_isRequested && !_isDisposed) {
        _isRequested = false;
        await reconciliation();
      }
    } finally {
      _isRunning = false;
    }
  }

  void dispose() {
    _isDisposed = true;
    _isRequested = false;
  }
}
