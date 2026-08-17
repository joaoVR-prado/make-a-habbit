import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/services/notification_schedule_planner.dart';

void main() {
  const planner = NotificationSchedulePlanner();

  HabitModel criarHabito({
    required HabitFrequencyType frequencia,
    List<int>? dias,
    String id = 'habito',
    DateTime? inicio,
    DateTime? fim,
  }) {
    return HabitModel(
      id: id,
      iconCode: 0,
      name: 'Beber água',
      conclusionType: HabitConclusionType.yesNo,
      frequency: HabitFrequency.fromType(type: frequencia, selectedDays: dias),
      startDate: inicio ?? DateTime(2026, 1, 1),
      endDate: fim,
      notificationId: planner.baseIdForHabit(id),
      notificationTime: DateTime(2026, 1, 1, 9, 30),
    );
  }

  group('Planejamento de lembretes diários e semanais', () {
    test('Cria um lembrete diário recorrente no horário escolhido.', () {
      final planos = planner.plan(
        habit: criarHabito(frequencia: HabitFrequencyType.daily),
        reminderEnabled: true,
        streakEnabled: false,
        now: DateTime(2026, 8, 8),
      );

      expect(planos, hasLength(1));
      final agenda = planos.single.schedule as RepeatingCalendarSchedule;
      expect(agenda.hour, 9);
      expect(agenda.minute, 30);
      expect(agenda.weekday, isNull);
      expect(agenda.day, isNull);
    });

    test('Cria um lembrete diferente para cada dia semanal.', () {
      final planos = planner.plan(
        habit: criarHabito(
          frequencia: HabitFrequencyType.weekly,
          dias: [DateTime.monday, DateTime.friday],
        ),
        reminderEnabled: true,
        streakEnabled: false,
        now: DateTime(2026, 8, 8),
      );

      expect(planos, hasLength(2));
      expect(
        planos.map(
          (plano) => (plano.schedule as RepeatingCalendarSchedule).weekday,
        ),
        [DateTime.monday, DateTime.friday],
      );
      expect(planos.map((plano) => plano.id).toSet(), hasLength(2));
    });
  });

  group('Planejamento de lembretes mensais', () {
    test('Mantém dias de 1 a 31 como recorrências mensais.', () {
      final planos = planner.plan(
        habit: criarHabito(
          frequencia: HabitFrequencyType.monthly,
          dias: [1, 15, 31],
        ),
        reminderEnabled: true,
        streakEnabled: false,
        now: DateTime(2026, 8, 8),
      );

      expect(planos, hasLength(3));
      expect(
        planos.map(
          (plano) => (plano.schedule as RepeatingCalendarSchedule).day,
        ),
        [1, 15, 31],
      );
    });

    test('Gera os próximos 12 últimos dias sem fixar fevereiro em 28.', () {
      final planos = planner.plan(
        habit: criarHabito(
          frequencia: HabitFrequencyType.monthly,
          dias: [NotificationSchedulePlanner.lastDayOfMonth],
        ),
        reminderEnabled: true,
        streakEnabled: false,
        now: DateTime(2028, 1, 1),
      );

      final datas = planos
          .map((plano) => (plano.schedule as ExactDateSchedule).date)
          .toList();
      expect(datas, hasLength(12));
      expect(datas[0], DateTime(2028, 1, 31, 9, 30));
      expect(datas[1], DateTime(2028, 2, 29, 9, 30));
      expect(datas[2], DateTime(2028, 3, 31, 9, 30));
    });

    test('Ignora a ocorrência do mês atual quando o horário já passou.', () {
      final planos = planner.plan(
        habit: criarHabito(
          frequencia: HabitFrequencyType.monthly,
          dias: [NotificationSchedulePlanner.lastDayOfMonth],
        ),
        reminderEnabled: true,
        streakEnabled: false,
        now: DateTime(2026, 1, 31, 10),
      );

      final primeiraData = (planos.first.schedule as ExactDateSchedule).date;
      expect(primeiraData, DateTime(2026, 2, 28, 9, 30));
    });
  });

  group('Identificadores e ofensiva', () {
    test('Gera id para o mesmo hábito.', () {
      expect(
        planner.baseIdForHabit('habito'),
        planner.baseIdForHabit('habito'),
      );
    });

    test('Não repete id entre ocorrências do mesmo hábito.', () {
      final planos = planner.plan(
        habit: criarHabito(
          frequencia: HabitFrequencyType.monthly,
          dias: [1, 15, NotificationSchedulePlanner.lastDayOfMonth],
        ),
        reminderEnabled: true,
        streakEnabled: true,
        now: DateTime(2026, 8, 8),
      );

      expect(planos.map((plano) => plano.id).toSet(), hasLength(planos.length));
    });

    test('Agenda a ofensiva diariamente ao meio dia.', () {
      final planos = planner.plan(
        habit: criarHabito(frequencia: HabitFrequencyType.daily),
        reminderEnabled: false,
        streakEnabled: true,
        now: DateTime(2026, 8, 8),
      );

      expect(planos, hasLength(1));
      expect(planos.single.category, PlannedNotificationCategory.streak);
      final agenda = planos.single.schedule as RepeatingCalendarSchedule;
      expect(agenda.hour, 12);
      expect(agenda.minute, 0);
    });

    test('Agenda a ofensiva somente nos dias do hábito semanal.', () {
      final planos = planner.plan(
        habit: criarHabito(
          frequencia: HabitFrequencyType.weekly,
          dias: [DateTime.monday, DateTime.friday],
        ),
        reminderEnabled: false,
        streakEnabled: true,
        now: DateTime(2026, 8, 8),
      );

      expect(planos, hasLength(2));
      expect(
        planos.map(
          (plano) => (plano.schedule as RepeatingCalendarSchedule).weekday,
        ),
        [DateTime.monday, DateTime.friday],
      );
    });

    test('Não cria agendamentos para um hábito encerrado.', () {
      final planos = planner.plan(
        habit: criarHabito(
          frequencia: HabitFrequencyType.daily,
          fim: DateTime(2026, 8, 7),
        ),
        reminderEnabled: true,
        streakEnabled: true,
        now: DateTime(2026, 8, 8),
      );

      expect(planos, isEmpty);
    });

    test('Não cria agendamentos antes do início do hábito.', () {
      final planos = planner.plan(
        habit: criarHabito(
          frequencia: HabitFrequencyType.daily,
          inicio: DateTime(2026, 8, 9),
        ),
        reminderEnabled: true,
        streakEnabled: true,
        now: DateTime(2026, 8, 8),
      );

      expect(planos, isEmpty);
    });

    test('Não cria recorrências que ultrapassem o término do hábito.', () {
      final fim = DateTime(2026, 8, 10);
      final planos = planner.plan(
        habit: criarHabito(frequencia: HabitFrequencyType.daily, fim: fim),
        reminderEnabled: true,
        streakEnabled: true,
        now: DateTime(2026, 8, 8),
      );

      expect(planos, isNotEmpty);
      expect(
        planos.every((plano) => plano.schedule is ExactDateSchedule),
        isTrue,
      );
      expect(
        planos
            .map((plano) => (plano.schedule as ExactDateSchedule).date)
            .every(
              (date) => !DateTime(date.year, date.month, date.day).isAfter(fim),
            ),
        isTrue,
      );
    });
  });
}
