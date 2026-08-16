import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/data/dtos/conclusion_dto.dart';
import 'package:make_a_habbit/data/dtos/habit_dto.dart';
import 'package:make_a_habbit/data/dtos/notification_config_dto.dart';
import 'package:make_a_habbit/domain/entities/conclusions/completion_value.dart';
import 'package:make_a_habbit/domain/entities/conclusions/concluded_habits_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';

void main() {
  group('MAPEAMENTO ENTRE HÁBITOS E DTO DO HIVE', () {
    for (final entry in <HabitFrequencyType, List<int>>{
      HabitFrequencyType.daily: const [],
      HabitFrequencyType.weekly: const [1, 3, 5],
      HabitFrequencyType.monthly: const [1, 15, 32],
    }.entries) {
      test('Preserva todos os campos na frequência ${entry.key.name}.', () {
        final original = HabitModel(
          id: 'habito-${entry.key.name}',
          iconCode: 2,
          name: 'Ler um livro',
          description: 'Descrição',
          conclusionType: HabitConclusionType.goalQuantity,
          goalQuantity: 10,
          frequency: HabitFrequency.fromType(
            type: entry.key,
            selectedDays: entry.value,
          ),
          startDate: DateTime(2026, 8, 14),
          endDate: DateTime(2026, 12, 31),
          notificationId: 123,
          notificationTime: DateTime(2026, 8, 14, 9, 30),
        );

        final restored = HabitDto.fromDomain(original).toDomain();

        expect(restored.id, original.id);
        expect(restored.iconCode, original.iconCode);
        expect(restored.name, original.name);
        expect(restored.description, original.description);
        expect(restored.conclusionType, original.conclusionType);
        expect(restored.goalQuantity, original.goalQuantity);
        expect(restored.frequency.type, original.frequency.type);
        expect(
          restored.frequency.selectedDays,
          original.frequency.selectedDays,
        );
        expect(restored.startDate, original.startDate);
        expect(restored.endDate, original.endDate);
        expect(restored.notificationId, original.notificationId);
        expect(restored.notificationTime, original.notificationTime);
      });
    }

    test('Salva os tipos do hábito usando nomes estáveis.', () {
      final habit = HabitModel(
        id: 'habito',
        iconCode: 2,
        name: 'Ler um livro',
        conclusionType: HabitConclusionType.yesNo,
        frequency: const DailyHabitFrequency(),
        startDate: DateTime(2026, 8, 16),
      );

      final dto = HabitDto.fromDomain(habit);

      expect(dto.conclusionTypeName, HabitConclusionType.yesNo.name);
      expect(dto.frequencyTypeName, HabitFrequencyType.daily.name);
    });

    test('Rejeita um tipo de conclusão persistido desconhecido.', () {
      final dto = HabitDto(
        id: 'habito',
        iconCode: 2,
        name: 'Ler um livro',
        conclusionTypeName: 'tipo-inexistente',
        goalQuantity: null,
        frequencyTypeName: HabitFrequencyType.daily.name,
        selectedDays: const [],
        startDate: DateTime(2026, 8, 16),
        endDate: null,
        description: null,
        notificationId: null,
        notificationTime: null,
      );

      expect(dto.toDomain, throwsA(isA<FormatException>()));
    });

    test('Rejeita um tipo de frequência persistido desconhecido.', () {
      final dto = HabitDto(
        id: 'habito',
        iconCode: 2,
        name: 'Ler um livro',
        conclusionTypeName: HabitConclusionType.yesNo.name,
        goalQuantity: null,
        frequencyTypeName: 'frequencia-inexistente',
        selectedDays: const [],
        startDate: DateTime(2026, 8, 16),
        endDate: null,
        description: null,
        notificationId: null,
        notificationTime: null,
      );

      expect(dto.toDomain, throwsA(isA<FormatException>()));
    });
  });

  group('MAPEAMENTO ENTRE CONCLUSÕES E DTO DO HIVE', () {
    test('Preserva uma conclusão do tipo sim ou não.', () {
      final original = ConcludedHabitsModel(
        habitId: 'habito',
        conclusionDate: DateTime(2026, 8, 14),
        conclusionValue: const YesNoCompletionValue(true),
        note: 'Finalmente consegui!',
      );

      final restored = ConclusionDto.fromDomain(original).toDomain();

      expect(restored.habitId, original.habitId);
      expect(restored.conclusionDate, original.conclusionDate);
      expect((restored.conclusionValue as YesNoCompletionValue).value, isTrue);
      expect(restored.note, original.note);
    });

    test('Preserva uma conclusão quantitativa.', () {
      final original = ConcludedHabitsModel(
        habitId: 'habito',
        conclusionDate: DateTime(2026, 8, 14),
        conclusionValue: QuantityCompletionValue(7),
      );

      final restored = ConclusionDto.fromDomain(original).toDomain();

      expect((restored.conclusionValue as QuantityCompletionValue).value, 7);
    });

    test('Rejeita uma conclusão sim ou não sem valor persistido.', () {
      final dto = ConclusionDto(
        habitId: 'habito',
        conclusionDate: DateTime(2026, 8, 16),
        isYesNo: true,
        yesNoValue: null,
        quantityValue: null,
        note: null,
      );

      expect(dto.toDomain, throwsA(isA<FormatException>()));
    });

    test('Rejeita uma conclusão quantitativa sem valor persistido.', () {
      final dto = ConclusionDto(
        habitId: 'habito',
        conclusionDate: DateTime(2026, 8, 16),
        isYesNo: false,
        yesNoValue: null,
        quantityValue: null,
        note: null,
      );

      expect(dto.toDomain, throwsA(isA<FormatException>()));
    });
  });

  group('MAPEAMENTO ENTRE NOTIFICAÇÃO E DTO DO HIVE', () {
    test('Preserva todas as configurações da notificação.', () {
      final original = NotificationConfigModel(
        isReminderEnabled: true,
        isStreakEnabled: true,
        customTimeNotification: [DateTime(2026, 8, 14, 8)],
      );

      final restored = NotificationConfigDto.fromDomain(original).toDomain();

      expect(restored.isReminderEnabled, isTrue);
      expect(restored.isStreakEnabled, isTrue);
      expect(restored.customTimeNotification, original.customTimeNotification);
    });
  });
}
