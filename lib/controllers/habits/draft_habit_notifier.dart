import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/data/models/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/habits/habit_type.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';
class DraftHabitState {
  final String name;
  final String description;
  final HabitConclusionType? conclusionType;
  final String goalQuantity;
  final HabitFrequencyType? frequencyType;
  final List<int> weeklyDays;
  final List<int> monthlyDays;
  final DateTime? startDate;
  final DateTime? endDate;
  final TimeOfDay? reminderTime;
  final bool isStreakEnabled;
  final String? existingId; 
  final HabitIcon? category; 

  DraftHabitState({
    this.name = '',
    this.description = '',
    this.conclusionType,
    this.goalQuantity = '',
    this.frequencyType,
    this.weeklyDays = const [],
    this.monthlyDays = const [],
    this.startDate,
    this.endDate,
    this.reminderTime,
    this.isStreakEnabled = false,
    this.existingId,
    this.category, 
  });

  DraftHabitState copyWith({
    String? name,
    String? description,
    HabitConclusionType? conclusionType,
    String? goalQuantity,
    HabitFrequencyType? frequencyType,
    List<int>? weeklyDays,
    List<int>? monthlyDays,
    DateTime? startDate,
    DateTime? endDate,
    TimeOfDay? reminderTime,
    bool? isStreakEnabled,
    String? existingId,
    HabitIcon? category,
    bool clearEndDate = false,
    bool clearReminderTime = false 
  }) {
    return DraftHabitState(
      name: name ?? this.name,
      description: description ?? this.description,
      conclusionType: conclusionType ?? this.conclusionType,
      goalQuantity: goalQuantity ?? this.goalQuantity,
      frequencyType: frequencyType ?? this.frequencyType,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      monthlyDays: monthlyDays ?? this.monthlyDays,
      startDate: startDate ?? this.startDate,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      reminderTime: clearReminderTime ? null : (reminderTime ?? this.reminderTime),
      isStreakEnabled: isStreakEnabled ?? this.isStreakEnabled,
      existingId: existingId ?? this.existingId,
      category: category ?? this.category,
    );
  }
}

class DraftHabitNotifier extends Notifier<DraftHabitState> {
  @override
  DraftHabitState build() {
    return DraftHabitState(
      startDate: DateTime.now(),
    );
  }

  void updateId(String id) {
    state = state.copyWith(existingId: id);

  }

  void updateCategory(HabitIcon category) {
    state = state.copyWith(category: category);

  }

  void updateName(String name) {
    state = state.copyWith(name: name);

  }
  
  void updateDescription(String description) {
    state = state.copyWith(description: description);

  }

  void updateConclusionType(HabitConclusionType type) {
    state = state.copyWith(conclusionType: type);

  }
  
  void updateGoalQuantity(String quantity) {
    state = state.copyWith(goalQuantity: quantity);

  }

  void updateFrequencyType(HabitFrequencyType type) {
    state = state.copyWith(frequencyType: type);

  }
  
  void updateWeeklyDays(List<int> days) {
    state = state.copyWith(weeklyDays: days);

  }

  void updateMonthlyDays(List<int> days) {
    state = state.copyWith(monthlyDays: days);

  }
  
  void updateStartDate(DateTime date) {
    state = state.copyWith(startDate: date);

  }

  void updateEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);

  }

  void updateReminderTime(TimeOfDay? time) {
    state = state.copyWith(reminderTime: time);

  }

  void toggleStreak(bool value) {
    state = state.copyWith(isStreakEnabled: value);

  }
  
  void clearEndDate() {
    state = state.copyWith(clearEndDate: true);
    
  }

  void clearReminderTime() {
    state = state.copyWith(clearReminderTime: true);

  }

  // Limpador de drafts
  void clear() {
    state = DraftHabitState(startDate: DateTime.now());

  }
  // Para Edicao de habitos
  void loadForEdit(HabitModel habit, NotificationConfigModel? config) {
    List<int> weekly = [];
    List<int> monthly = [];
    
    if (habit.frequency.type == HabitFrequencyType.weekly) {
      weekly = habit.frequency.selectedDays ?? [];
    } else if (habit.frequency.type == HabitFrequencyType.monthly) {
      monthly = habit.frequency.selectedDays ?? [];
    }

    state = DraftHabitState(
      existingId: habit.id,
      name: habit.name,
      conclusionType: habit.conclusionType,
      goalQuantity: habit.goalQuantity?.toString() ?? '',
      description: habit.description ?? '',
      category: HabitIcon.fromCode(habit.iconCode),
      frequencyType: habit.frequency.type,
      weeklyDays: weekly,
      monthlyDays: monthly,
      startDate: habit.startDate,
      endDate: habit.endDate,
      reminderTime: habit.notificationTime != null 
          ? TimeOfDay.fromDateTime(habit.notificationTime!) 
          : null,
      
      isStreakEnabled: config?.isStreakEnabled ?? false,
    );
  }
}

final draftHabitProvider = NotifierProvider<DraftHabitNotifier, DraftHabitState>(() {
  return DraftHabitNotifier();

});