import 'package:flutter_test/flutter_test.dart';
import 'package:make_a_habbit/data/dtos/persisted_field_reader.dart';

void main() {
  group('LEITURA SEGURA DE CAMPOS PERSISTIDOS', () {
    test('Lê campos obrigatórios e opcionais válidos.', () {
      final fields = <int, Object?>{0: 'habito', 1: 3, 2: null};

      expect(readRequiredField<String>(fields, 0, 'id'), 'habito');
      expect(readRequiredIntField(fields, 1, 'quantidade'), 3);
      expect(readOptionalField<String>(fields, 2, 'nota'), isNull);
    });

    test('Informa o nome do campo obrigatório ausente.', () {
      expect(
        () => readRequiredField<String>(const {}, 0, 'habit.id'),
        throwsA(
          isA<FormatException>().having(
            (error) => error.message,
            'mensagem',
            contains('habit.id'),
          ),
        ),
      );
    });

    test('Rejeita campo opcional com tipo incorreto.', () {
      expect(
        () => readOptionalField<DateTime>(
          const {0: '2026-08-16'},
          0,
          'habit.endDate',
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('Rejeita lista que contém um elemento de tipo incorreto.', () {
      expect(
        () => readRequiredListField<int>(
          const {
            0: [1, 'segunda'],
          },
          0,
          'habit.selectedDays',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
