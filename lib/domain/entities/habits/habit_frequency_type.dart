enum HabitFrequencyType { daily, weekly, monthly }

extension HabitFrequencyTypeUI on HabitFrequencyType {
  String get title => switch (this) {
    HabitFrequencyType.daily => 'Todos os dias',
    HabitFrequencyType.weekly => 'Alguns dias da semana',
    HabitFrequencyType.monthly => 'Dias específicos do mês',
  };
}
