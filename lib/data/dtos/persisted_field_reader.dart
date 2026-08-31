T readRequiredField<T>(Map<int, Object?> fields, int index, String fieldName) {
  final value = fields[index];
  if (value is T) return value;
  throw FormatException(
    'Campo obrigatório "$fieldName" ausente ou inválido. '
    'Esperado: $T; recebido: ${value.runtimeType}.',
  );
}

T? readOptionalField<T>(Map<int, Object?> fields, int index, String fieldName) {
  final value = fields[index];
  if (value == null) return null;
  if (value is T) return value as T;
  throw FormatException(
    'Campo opcional "$fieldName" inválido. '
    'Esperado: $T; recebido: ${value.runtimeType}.',
  );
}

int readRequiredIntField(
  Map<int, Object?> fields,
  int index,
  String fieldName,
) {
  final value = fields[index];
  if (value is int) return value;
  throw FormatException(
    'Campo obrigatório "$fieldName" ausente ou inválido. '
    'Esperado: int; recebido: ${value.runtimeType}.',
  );
}

int? readOptionalIntField(
  Map<int, Object?> fields,
  int index,
  String fieldName,
) {
  final value = fields[index];
  if (value == null) return null;
  if (value is int) return value;
  throw FormatException(
    'Campo opcional "$fieldName" inválido. '
    'Esperado: int; recebido: ${value.runtimeType}.',
  );
}

List<T> readRequiredListField<T>(
  Map<int, Object?> fields,
  int index,
  String fieldName,
) {
  final value = fields[index];
  if (value is! List) {
    throw FormatException(
      'Campo obrigatório "$fieldName" ausente ou inválido. '
      'Esperado: List<$T>; recebido: ${value.runtimeType}.',
    );
  }
  if (value.any((item) => item is! T)) {
    throw FormatException(
      'Campo "$fieldName" contém elementos de tipo inválido. '
      'Esperado: List<$T>.',
    );
  }
  return List<T>.unmodifiable(value.cast<T>());
}
