import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> tapFlowButton(WidgetTester tester, {bool finish = false}) async {
  final buttonText = finish ? 'FINALIZAR' : 'PRÓXIMA';
  final buttonKey = finish
      ? const ValueKey('finish_habit_creation')
      : const ValueKey('next_habit_creation');
  final button = find.byKey(buttonKey);

  expect(
    button,
    findsOneWidget,
    reason: 'O botão "$buttonText" deveria estar visível.',
  );

  await tester.tap(button);
  await tester.pumpAndSettle();
}
