import 'package:hive_ce/hive.dart';

part 'completion_value.g.dart';

sealed class CompletionValue {
  const CompletionValue();
}

@HiveType(typeId: 11)
final class YesNoCompletionValue extends CompletionValue {
  const YesNoCompletionValue(this.value);

  @HiveField(0)
  final bool value;
}

@HiveType(typeId: 12)
final class QuantityCompletionValue extends CompletionValue {
  QuantityCompletionValue(this.value) {
    if (value < 0) {
      throw ArgumentError.value(value, 'value', 'A quantidade não pode ser negativa.');
    }
  }

  @HiveField(0)
  final int value;
}
