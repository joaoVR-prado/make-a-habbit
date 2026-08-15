import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/data/providers/habit_repository_provider.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';
import 'package:make_a_habbit/data/providers/notification_config_repository_provider.dart';
import 'package:make_a_habbit/data/providers/notification_scheduler_provider.dart';
import 'package:make_a_habbit/domain/repositories/conclusion_repository.dart';
import 'package:make_a_habbit/domain/repositories/habit_repository.dart';
import 'package:make_a_habbit/domain/repositories/notification_config_repository.dart';
import 'package:make_a_habbit/domain/services/notification_scheduler.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitRepository extends Mock implements HabitRepository {}
class _MockConclusionRepository extends Mock implements ConclusionRepository {}
class _MockNotificationConfigRepository extends Mock
    implements NotificationConfigRepository {}
class _NoopNotificationScheduler implements NotificationScheduler {
  @override
  Future<void> cancelForHabit(String habitId) async {}
  @override
  Future<bool> isPermissionGranted() async => true;
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> replaceSchedules({required HabitModel habit, required bool reminderEnabled, required bool streakEnabled, required DateTime now, int currentStreak = 0}) async {}
}

void main() {
  late _MockHabitRepository repository;
  late _MockConclusionRepository conclusions;
  late _MockNotificationConfigRepository notifications;
  late ProviderContainer container;
  late HabitModel habit;

  setUp(() async {
    habit = HabitModel(
      id: 'habito',
      iconCode: 0,
      name: 'Beber água',
      conclusionType: HabitConclusionType.yesNo,
      frequency: HabitFrequency.fromType(type: HabitFrequencyType.daily),
      startDate: DateTime(2026, 8, 8),
    );
    repository = _MockHabitRepository();
    conclusions = _MockConclusionRepository();
    notifications = _MockNotificationConfigRepository();
    when(() => repository.getAll()).thenReturn([habit]);
    container = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(repository),
        concludedHabitsRepositoryProvider.overrideWithValue(conclusions),
        notificationConfigRepositoryProvider.overrideWithValue(notifications),
        notificationSchedulerProvider.overrideWithValue(_NoopNotificationScheduler()),
      ],
    );
    addTearDown(container.dispose);
    await container.read(habitControllerProvider.future);
  });

  group('TESTES DE ESTADO DA EXCLUSÃO DE UM HÁBITO', () {
    test('Remove o estado de um hábito apenas se o repositório tiver sucesso.', () async {
      final deletion = Completer<void>();
    when(() => conclusions.deleteByHabit(habit.id)).thenAnswer((_) async {});
    when(() => notifications.delete(habit.id)).thenAnswer((_) async {});
    when(() => repository.delete(habit.id)).thenAnswer(
        (_) => deletion.future,
      );

      final future = container
        .read(habitControllerProvider.notifier)
        .deleteHabit(habit.id);

      await Future<void>.delayed(Duration.zero);
      expect(container.read(habitControllerProvider), isA<AsyncLoading>());
    deletion.complete();
    await future;
    expect(container.read(habitControllerProvider).requireValue, isEmpty);
    verify(() => conclusions.deleteByHabit(habit.id)).called(1);
    verify(() => notifications.delete(habit.id)).called(1);
    verify(() => repository.delete(habit.id)).called(1);
    });

    test('Mantém o hábito caso o repositório falhe em apagar o mesmo.', () async {
    when(() => conclusions.deleteByHabit(habit.id)).thenAnswer((_) async {});
    when(() => notifications.delete(habit.id)).thenAnswer((_) async {});
    when(() => repository.delete(habit.id)).thenThrow(
        Exception('Falha no armazenamento'),
      );

      await expectLater(
        container.read(habitControllerProvider.notifier).deleteHabit(habit.id),
        throwsException,
      );

      expect(container.read(habitControllerProvider), isA<AsyncError>());
    });
  });

}
