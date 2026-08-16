import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency.dart';
import 'package:make_a_habbit/controllers/habits/habit_controller.dart';
import 'package:make_a_habbit/core/providers/clock_provider.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_frequency_type.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_model.dart';
import 'package:make_a_habbit/domain/entities/habits/habit_type.dart';
import 'package:make_a_habbit/domain/services/clock.dart';
import 'package:make_a_habbit/presentation/habits/widgets/edit_or_complete_habit_dialog.dart';

class _FixedClock implements Clock {
  @override
  DateTime now() => DateTime(2026, 8, 16, 12);
}

void main() {
  final habit = HabitModel(
    id: 'habito',
    iconCode: 0,
    name: 'Beber água',
    conclusionType: HabitConclusionType.yesNo,
    frequency: HabitFrequency.fromType(type: HabitFrequencyType.daily),
    startDate: DateTime(2026, 8, 8),
  );

  Future<void> openDialog(
    WidgetTester tester,
    Future<void> Function(WidgetRef ref) deleteHabit,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => EditOrCompleteHabitDialog(
                    habit: habit,
                    deleteHabit: deleteHabit,
                  ),
                ),
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EXCLUIR HÁBITO'));
    await tester.pumpAndSettle();
  }

  group(
    'TESTES DO WIDGET DAILOG DE CONCLUIR, EDITAR OU EXCLUIR UM HÁBITO.',
    () {
      testWidgets(
        'Mantém o dialog aberto e bloqueia ações enquanto a exclusão ocorre.',
        (tester) async {
          final deletion = Completer<void>();
          var calls = 0;
          await openDialog(tester, (_) {
            calls++;
            return deletion.future;
          });

          await tester.tap(find.text('Confirmar'));
          await tester.pump();

          expect(calls, 1);
          expect(find.byType(AlertDialog), findsNWidgets(2));
          expect(find.byType(CircularProgressIndicator), findsOneWidget);
          final cancelButton = tester.widget<TextButton>(
            find.widgetWithText(TextButton, 'Cancelar'),
          );
          expect(cancelButton.onPressed, isNull);

          deletion.complete();
          await tester.pumpAndSettle();

          expect(find.byType(AlertDialog), findsNothing);
          expect(find.text('Hábito excluído com sucesso!'), findsOneWidget);
        },
      );

      testWidgets(
        'Mantém a confirmação aberta e mostra mensagem de erro caso ocorra.',
        (tester) async {
          var calls = 0;
          await openDialog(tester, (_) async {
            calls++;
            throw Exception('Erro de armazenamento');
          });

          await tester.tap(find.text('Confirmar'));
          await tester.pumpAndSettle();

          expect(calls, 1);
          expect(find.byType(AlertDialog), findsNWidgets(2));
          expect(find.byKey(const Key('delete_habit_error')), findsOneWidget);
          expect(
            find.text('Não foi possível excluir o hábito. Tente novamente!'),
            findsOneWidget,
          );
          expect(find.text('Confirmar'), findsOneWidget);
        },
      );

      testWidgets('Bloqueia a conclusão quando a data selecionada é futura.', (
        tester,
      ) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              clockProvider.overrideWithValue(_FixedClock()),
              selectedDateProvider.overrideWith((ref) => DateTime(2026, 8, 17)),
            ],
            child: MaterialApp(
              home: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (_) => EditOrCompleteHabitDialog(habit: habit),
                    ),
                    child: const Text('Abrir'),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.tap(find.text('Abrir'));
        await tester.pumpAndSettle();

        expect(
          find.text('Não é possível concluir um hábito em uma data futura.'),
          findsOneWidget,
        );
        final concludeButton = tester.widget<TextButton>(
          find.widgetWithText(TextButton, 'CONCLUIR'),
        );
        expect(concludeButton.onPressed, isNull);
      });
    },
  );
}
