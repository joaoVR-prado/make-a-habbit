import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/data/models/concluded_habits/completion_value.dart';

void main() {
  group('Valores de conclusão', () {
    test('Mantém o valor bool informado.', () {
      const value = YesNoCompletionValue(true);

      expect(value.value, isTrue);
    });

    test('Mantém a quantidade informada.', () {
      final value = QuantityCompletionValue(3);

      expect(value.value, 3);
    });

    test('Rejeita uma quantidade negativa.', () {
      expect(
        () => QuantityCompletionValue(-1),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
