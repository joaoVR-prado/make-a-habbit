sealed class CompletionValue {
  const CompletionValue();
}

final class YesNoCompletionValue extends CompletionValue {
  const YesNoCompletionValue(this.value);
  final bool value;
}

final class QuantityCompletionValue extends CompletionValue {
  QuantityCompletionValue(this.value) {
    if (value < 0) throw ArgumentError.value(value, 'value', 'A quantidade não pode ser negativa.');
  }
  final int value;
}
