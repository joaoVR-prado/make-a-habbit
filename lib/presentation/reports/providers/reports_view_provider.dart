import 'package:flutter_riverpod/legacy.dart';

enum ReportsView { general, habits }

final reportsViewProvider = StateProvider.autoDispose<ReportsView>(
  (ref) => ReportsView.general,
);
