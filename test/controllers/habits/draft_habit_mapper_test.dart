import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_mapper.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';

void main() {
  group('CONVERSÃO DO RASCUNHO DE HÁBITO', () {
    test('Cria hábito e notificação com valores determinísticos.', () {
      final mapper = DraftHabitMapper(generateId: () => 'habit-id');
      final result = mapper(
        DraftHabitState(
          name: 'Beber água',
          description: 'Dois litros por dia',
          category: HabitIcon.healthIcon,
          conclusionType: HabitConclusionType.goalQuantity,
          goalQuantity: '8',
          frequencyType: HabitFrequencyType.weekly,
          weeklyDays: const [1, 3, 5],
          startDate: DateTime(2026, 8, 29),
          reminderTime: const TimeOfDay(hour: 9, minute: 30),
          isStreakEnabled: true,
        ),
        now: DateTime(2026, 8, 29, 18),
      );

      expect(result.isEditing, isFalse);
      expect(result.habit.id, 'habit-id');
      expect(result.habit.frequency.selectedDays, [1, 3, 5]);
      expect(result.habit.goalQuantity, 8);
      expect(result.habit.notificationTime, DateTime(2026, 8, 29, 9, 30));
      expect(result.notification.isReminderEnabled, isTrue);
      expect(result.notification.isStreakEnabled, isTrue);
      expect(result.notification.customTimeNotification, [
        DateTime(2026, 8, 29, 9, 30),
      ]);
    });

    test('Preserva o identificador ao converter uma edição.', () {
      var generatedIds = 0;
      final mapper = DraftHabitMapper(
        generateId: () {
          generatedIds++;
          return 'novo-id';
        },
      );

      final result = mapper(
        DraftHabitState(
          existingId: 'habit-existente',
          name: 'Ler',
          category: HabitIcon.studiesIcon,
          conclusionType: HabitConclusionType.yesNo,
          frequencyType: HabitFrequencyType.daily,
          startDate: DateTime(2026, 8, 1),
        ),
        now: DateTime(2026, 8, 29),
      );

      expect(result.isEditing, isTrue);
      expect(result.habit.id, 'habit-existente');
      expect(generatedIds, 0);
    });

    test('Informa campos obrigatórios ausentes com erro de validação.', () {
      expect(
        () => const DraftHabitMapper()(
          DraftHabitState(name: 'Ler'),
          now: DateTime(2026, 8, 29),
        ),
        throwsA(
          isA<DraftHabitValidationException>().having(
            (error) => error.message,
            'mensagem',
            'Preencha todos os campos obrigatórios.',
          ),
        ),
      );
    });

    test('Informa frequência semanal vazia como erro de validação.', () {
      expect(
        () => const DraftHabitMapper()(
          DraftHabitState(
            name: 'Ler',
            category: HabitIcon.studiesIcon,
            conclusionType: HabitConclusionType.yesNo,
            frequencyType: HabitFrequencyType.weekly,
            startDate: DateTime(2026, 8, 29),
          ),
          now: DateTime(2026, 8, 29),
        ),
        throwsA(isA<DraftHabitValidationException>()),
      );
    });
  });
}
