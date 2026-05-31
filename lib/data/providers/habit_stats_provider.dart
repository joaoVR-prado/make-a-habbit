import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/models/reports/habit_stats_model.dart';
import 'package:make_a_habbit/data/providers/concluded_habits_repository_provider.dart';

final habitStatsProvider = Provider.autoDispose<HabitStatsModel>((ref) {
  final habits = ref.watch(habitControllerProvider);
  final conclusions = ref.watch(concludedHabitsControllerProvider);

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  DateTime normalizeDate(DateTime d) => DateTime(d.year, d.month, d.day);

  bool isCompleted(HabitModel habit, dynamic conclusion){
    if(conclusion == null) return false;
    if(habit.conclusionType == HabitConclusionType.goalQuantity){
      return conclusion.value >= (habit.goalQuantity ?? 1);

    }

    return conclusion.value >0;

  }

  // Total ativos
  int totalActive = habits.length;

  // Concluidos hoje e Gráfico Semanal
  int completedToday = 0;
  final Map<DateTime, int> weeklyData = {};

  for(int i =6; i>= 0; i++){
    final targetDate = today.subtract(Duration(days: i));
    int completedOnThisDay = 0;

    for(var habit in habits){
      final conclusion = conclusions.where((c) => 
        c.habitId == habit.id && normalizeDate(c.conclusionDate) == targetDate
      ).firstOrNull;

      if(isCompleted(habit, conclusion)){
        completedOnThisDay++;
        if(i == 0) completedToday++;

      }
    }
    weeklyData[targetDate] = completedOnThisDay; 

  }

  // Taxa de Sucesso dos últimos 30 dias
  int totalActiveDaysLast30 = 0;
  int totalCompleteLast30 = 0;

  for(int i = 0; i < 30; i++){
    final date = today.subtract(Duration(days: i));
    for(var habit in habits){
      if(habit.isHabitActiveOn(date)){
        totalActiveDaysLast30++;
        final conclusion = conclusions.where((c) => 
          c.habitId == habit.id && normalizeDate(c.conclusionDate) == date 
        ).firstOrNull;

        if(isCompleted(habit, conclusion)){
          totalActiveDaysLast30++;

        }

      }

    }

  }

  double successRate = totalCompleteLast30 == 0
    ? 0.0
    : (totalCompleteLast30 / totalActiveDaysLast30) * 100;

  // Melhor Ofensiva
  int bestStreakGeral = 0;

  for(var habit in habits){
    final habitCompletedDates = conclusions
      .where((c) => c.habitId == habit.id && isCompleted(habit, c))
      .map((c) => normalizeDate(c.conclusionDate))
      .toSet()
      .toList();

    habitCompletedDates.sort((a, b) => a.compareTo(b));

    int currentStreak = 0;
    int maxHabitStreak = 0;
    DateTime? previousDate;

    for (var date in habitCompletedDates) {
      if (previousDate == null) {
        currentStreak = 1;
      } else {
        final diffInDays = date.difference(previousDate).inDays;
        
        if (diffInDays == 1) {
          currentStreak++;
        } else {
          bool brokeStreak = false;
          for (int j = 1; j < diffInDays; j++) {
            final intermediateDate = previousDate.add(Duration(days: j));
            if (habit.isHabitActiveOn(intermediateDate)) {
              brokeStreak = true; 
              break;
            }
          }
          if (brokeStreak) {
            currentStreak = 1; 
          } else {
            currentStreak++; 
          }
        }
      }
      
      if (currentStreak > maxHabitStreak) maxHabitStreak = currentStreak;
      previousDate = date;
    }
    
    if (maxHabitStreak > bestStreakGeral) bestStreakGeral = maxHabitStreak;

  }

  // Monta os dados para o Card
  return HabitStatsModel(
    totalHabits: totalActive,
    completedToday: completedToday,
    generalSuccessRate: successRate,
    bestStreakGeral: bestStreakGeral,
    weeklyCompletionHistory: weeklyData,

  );  

  // TESTE COM DADOS MOCKADOS
  // final now = DateTime.now();
  // final today = DateTime(now.year, now.month, now.day);
  
  // // DADOS FALSOS DE TESTE:
  // final Map<DateTime, int> mockWeeklyData = {
  //   today.subtract(const Duration(days: 0)): 5,
  //   today.subtract(const Duration(days: 1)): 3, 
  //   today.subtract(const Duration(days: 2)): 4,
  //   today.subtract(const Duration(days: 3)): 0, 
  //   today.subtract(const Duration(days: 4)): 2,
  //   today.subtract(const Duration(days: 5)): 6,
  //   today.subtract(const Duration(days: 6)): 4,
  // };

  // return HabitStatsModel(
  //   totalHabits: 12,
  //   completedToday: 5,
  //   generalSuccessRate: 85.5,
  //   bestStreakGeral: 14,
  //   weeklyCompletionHistory: mockWeeklyData,

  // );

});