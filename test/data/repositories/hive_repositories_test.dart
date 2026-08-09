import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/models/concluded_habits/concluded_habits_model.dart';
import 'package:make_a_habbit/data/models/concluded_habits/completion_value.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';
import 'package:make_a_habbit/data/repositories/concluded_habits_repository.dart';
import 'package:make_a_habbit/data/repositories/habit_repository.dart';
import 'package:make_a_habbit/data/repositories/notification_config_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitBox extends Mock implements Box<HabitModel> {}
class _MockConclusionBox extends Mock implements Box<ConcludedHabitsModel> {}
class _MockNotificationBox extends Mock
    implements Box<NotificationConfigModel> {}

void main() {
  final habit = HabitModel(
    id: 'habito',
    iconCode: 0,
    name: 'Beber água',
    conclusionType: HabitConclusionType.yesNo,
    frequency: HabitFrequency(type: HabitFrequencyType.daily),
    startDate: DateTime(2026, 8, 8),
  );
  final notification = NotificationConfigModel(
    isReminderEnabled: true,
    isStreakEnabled: false,
    customTimeNotification: [DateTime(2026, 8, 8, 9)],
  );

  group('HiveHabitRepository', () {
    test('Testa as operações básicas na BOX.', () async {
      final box = _MockHabitBox();
      when(() => box.values).thenReturn([habit]);
      when(() => box.get(habit.id)).thenReturn(habit);
      when(() => box.put(habit.id, habit)).thenAnswer((_) async {});
      when(() => box.delete(habit.id)).thenAnswer((_) async {});
      when(() => box.clear()).thenAnswer((_) async => 1);
      final repository = HiveHabitRepository(box);

      expect(repository.getAll(), [habit]);
      expect(repository.getById(habit.id), habit);
      await repository.add(habit);
      await repository.update(habit);
      await repository.delete(habit.id);
      await repository.clear();

      verify(() => box.put(habit.id, habit)).called(2);
      verify(() => box.delete(habit.id)).called(1);
      verify(() => box.clear()).called(1);
    });
  });

  group('HiveNotificationConfigRepository', () {
    test('Salva, carrega, deleta e limpa a BOX.', () async {
      final box = _MockNotificationBox();
      when(() => box.get(habit.id)).thenReturn(notification);
      when(() => box.put(habit.id, notification)).thenAnswer((_) async {});
      when(() => box.delete(habit.id)).thenAnswer((_) async {});
      when(() => box.clear()).thenAnswer((_) async => 1);
      final repository = HiveNotificationConfigRepository(box);

      expect(repository.get(habit.id), notification);
      await repository.save(habit.id, notification);
      await repository.delete(habit.id);
      await repository.clear();

      verify(() => box.put(habit.id, notification)).called(1);
      verify(() => box.delete(habit.id)).called(1);
      verify(() => box.clear()).called(1);
    });
  });

  group('HiveConclusionRepository', () {
    test('Deleta os dados que pertencem ao hábito.', () async {
      final box = _MockConclusionBox();
      final target = ConcludedHabitsModel(
        habitId: habit.id,
        conclusionDate: DateTime(2026, 8, 8),
        conclusionValue: const YesNoCompletionValue(true),
      );
      final other = ConcludedHabitsModel(
        habitId: 'habito2',
        conclusionDate: DateTime(2026, 8, 8),
        conclusionValue: const YesNoCompletionValue(true),
      );
      when(() => box.keys).thenReturn(['target', 'other']);
      when(() => box.get('target')).thenReturn(target);
      when(() => box.get('other')).thenReturn(other);
      when(() => box.deleteAll(any())).thenAnswer((_) async {});
      final repository = HiveConclusionRepository(box);

      await repository.deleteByHabit(habit.id);

      final deletedKeys = verify(() => box.deleteAll(captureAny())).captured.single;
      expect(deletedKeys, ['target']);
    });

    test('Testa a chave da BOX ao salvar.', () async {
      final box = _MockConclusionBox();
      final conclusion = ConcludedHabitsModel(
        habitId: habit.id,
        conclusionDate: DateTime(2026, 8, 8, 19, 30),
        conclusionValue: const YesNoCompletionValue(true),
      );
      when(
        () => box.put('habito_2026-8-8', conclusion),
      ).thenAnswer((_) async {});
      final repository = HiveConclusionRepository(box);

      await repository.save(conclusion);

      verify(() => box.put('habito_2026-8-8', conclusion)).called(1);
    });
  });
}
