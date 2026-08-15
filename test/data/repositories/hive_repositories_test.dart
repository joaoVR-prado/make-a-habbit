import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';
import 'package:make_a_habbit/data/repositories/concluded_habits_repository.dart';
import 'package:make_a_habbit/data/repositories/habit_repository.dart';
import 'package:make_a_habbit/data/repositories/notification_config_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockHabitBox extends Mock implements Box<HabitDto> {}
class _MockConclusionBox extends Mock implements Box<ConclusionDto> {}
class _MockNotificationBox extends Mock
    implements Box<NotificationConfigDto> {}

void main() {
  final habit = HabitModel(
    id: 'habito',
    iconCode: 0,
    name: 'Beber água',
    conclusionType: HabitConclusionType.yesNo,
    frequency: HabitFrequency.fromType(type: HabitFrequencyType.daily),
    startDate: DateTime(2026, 8, 8),
  );
  final notification = NotificationConfigModel(
    isReminderEnabled: true,
    isStreakEnabled: false,
    customTimeNotification: [DateTime(2026, 8, 8, 9)],
  );
  final habitDto = HabitDto.fromDomain(habit);
  final notificationDto = NotificationConfigDto.fromDomain(notification);
  final conclusionFallback = ConclusionDto.fromDomain(
    ConcludedHabitsModel(
      habitId: 'fallback',
      conclusionDate: DateTime(2026, 8, 8),
      conclusionValue: const YesNoCompletionValue(false),
    ),
  );

  setUpAll(() {
    registerFallbackValue(habitDto);
    registerFallbackValue(notificationDto);
    registerFallbackValue(conclusionFallback);
  });

  group('HiveHabitRepository', () {
    test('Testa as operações básicas na BOX.', () async {
      final box = _MockHabitBox();
      when(() => box.values).thenReturn([habitDto]);
      when(() => box.get(habit.id)).thenReturn(habitDto);
      when(() => box.put(habit.id, any())).thenAnswer((_) async {});
      when(() => box.delete(habit.id)).thenAnswer((_) async {});
      when(() => box.clear()).thenAnswer((_) async => 1);
      final repository = HiveHabitRepository(box);

      expect(repository.getAll().single.id, habit.id);
      expect(repository.getById(habit.id)?.name, habit.name);
      await repository.add(habit);
      await repository.update(habit);
      await repository.delete(habit.id);
      await repository.clear();

      final savedDtos = verify(() => box.put(habit.id, captureAny())).captured;
      expect(savedDtos, hasLength(2));
      expect(savedDtos.cast<HabitDto>().every((dto) => dto.toDomain().id == habit.id), isTrue);
      verify(() => box.delete(habit.id)).called(1);
      verify(() => box.clear()).called(1);
    });
  });

  group('HiveNotificationConfigRepository', () {
    test('Salva, carrega, deleta e limpa a BOX.', () async {
      final box = _MockNotificationBox();
      when(() => box.get(habit.id)).thenReturn(notificationDto);
      when(() => box.put(habit.id, any())).thenAnswer((_) async {});
      when(() => box.delete(habit.id)).thenAnswer((_) async {});
      when(() => box.clear()).thenAnswer((_) async => 1);
      final repository = HiveNotificationConfigRepository(box);

      expect(repository.get(habit.id)?.isReminderEnabled, isTrue);
      await repository.save(habit.id, notification);
      await repository.delete(habit.id);
      await repository.clear();

      final savedDto = verify(() => box.put(habit.id, captureAny())).captured.single
          as NotificationConfigDto;
      expect(savedDto.toDomain().customTimeNotification, notification.customTimeNotification);
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
      final targetDto = ConclusionDto.fromDomain(target);
      final otherDto = ConclusionDto.fromDomain(other);
      when(() => box.keys).thenReturn(['target', 'other']);
      when(() => box.get('target')).thenReturn(targetDto);
      when(() => box.get('other')).thenReturn(otherDto);
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
        () => box.put('habito_2026-8-8', any()),
      ).thenAnswer((_) async {});
      final repository = HiveConclusionRepository(box);

      await repository.save(conclusion);

      final savedDto = verify(
        () => box.put('habito_2026-8-8', captureAny()),
      ).captured.single as ConclusionDto;
      expect(savedDto.toDomain().habitId, conclusion.habitId);
    });
  });
}
