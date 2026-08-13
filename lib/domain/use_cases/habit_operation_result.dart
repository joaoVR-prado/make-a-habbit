enum HabitOperationFailure {
  notificationConfig,
  notificationSchedule,
  conclusions,
}

final class HabitOperationResult {
  const HabitOperationResult({this.failures = const {}});

  final Set<HabitOperationFailure> failures;

  bool get hasPartialFailures => failures.isNotEmpty;
}
