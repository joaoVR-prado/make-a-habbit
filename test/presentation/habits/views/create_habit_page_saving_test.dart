import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/controllers/habits/draft_habit_notifier.dart';
import 'package:make_a_habbit/core/utils/enums/habit_icon.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/entities/notifications/notification_config_model.dart';
import 'package:make_a_habbit/domain/use_cases/habit_operation_result.dart';
import 'package:make_a_habbit/presentation/habits/views/create_habit_page.dart';

void main() {
  group('SALVAMENTO DO HÁBITO', () {
    testWidgets(
      'Impede um segundo salvamento enquanto o primeiro está em andamento.',
      (tester) async {
        final saveCompleter = Completer<HabitOperationResult>();
        var saveCalls = 0;

        await _openCreateHabitPage(
          tester,
          saveHabit: (habit, notification, isEditing) {
            saveCalls++;
            return saveCompleter.future;
          },
        );
        await _advanceToLastPage(tester);

        await tester.tap(find.text('FINALIZAR'));
        await tester.tap(find.text('FINALIZAR'));
        await tester.pump();

        expect(saveCalls, 1);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        saveCompleter.complete(const HabitOperationResult());
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Exibe uma mensagem quando a persistência falha.',
      (tester) async {
        await _openCreateHabitPage(
          tester,
          saveHabit: (habit, notification, isEditing) async {
            throw Exception('Falha no armazenamento local');
          },
        );
        await _advanceToLastPage(tester);

        await tester.tap(find.text('FINALIZAR'));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('save_habit_error')), findsOneWidget);
        expect(
          find.text('Não foi possível salvar o hábito. Tente novamente.'),
          findsOneWidget,
        );
        expect(find.text('FINALIZAR'), findsOneWidget);
      },
    );
  });
}

Future<void> _openCreateHabitPage(
  WidgetTester tester, {
  required Future<HabitOperationResult> Function(
    HabitModel habit,
    NotificationConfigModel notification,
    bool isEditing,
  ) saveHabit,
}) async {
  final draft = DraftHabitState(
    name: 'Beber água',
    category: HabitIcon.healthIcon,
    conclusionType: HabitConclusionType.yesNo,
    frequencyType: HabitFrequencyType.daily,
    startDate: DateTime(2026, 8, 15),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        draftHabitInitialStateProvider.overrideWithValue(draft),
      ],
      child: MaterialApp(
        home: CreateHabitPage(saveHabit: saveHabit),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _advanceToLastPage(WidgetTester tester) async {
  for (var page = 0; page < 4; page++) {
    await tester.tap(find.text('PRÓXIMA'));
    await tester.pumpAndSettle();
  }
}
