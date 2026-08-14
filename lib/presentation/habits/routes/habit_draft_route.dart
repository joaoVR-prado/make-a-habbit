import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/data/models/habits/habit_model.dart';
import 'package:make_a_habbit/data/models/notifications/notification_config_model.dart';
import 'package:make_a_habbit/presentation/habits/views/create_habit_page.dart';

abstract final class HabitDraftRoute {
  static Route<void> create() => _route(null);

  static Route<void> edit({
    required HabitModel habit,
    NotificationConfigModel? notificationConfig,
  }) {
    return _route(DraftHabitState.forEdit(habit, notificationConfig));
  }

  static Route<void> _route(DraftHabitState? initialState) {
    return MaterialPageRoute<void>(
      builder: (_) => ProviderScope(
        overrides: [
          draftHabitInitialStateProvider.overrideWithValue(initialState),
        ],
        child: const CreateHabitPage(),
      ),
    );
  }
}
