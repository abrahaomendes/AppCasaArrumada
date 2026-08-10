class AppWeek {
  final int year;
  final int week;

  AppWeek(this.year, this.week);

  @override
  String toString() => 'Semana $week / $year';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppWeek &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          week == other.week;

  @override
  int get hashCode => year.hashCode ^ week.hashCode;
}

class WeekCalculator {
  /// Retorna o número da semana (adaptado) e o ano correspondente.
  /// Para que a semana comece no Domingo e termine no Sábado (em vez de Seg-Dom da ISO),
  /// adicionamos 1 dia à data antes de calcular a semana ISO.
  static AppWeek getAppWeek(DateTime date) {
    // Desloca a data em 1 dia. Assim, o Domingo vira Segunda (início da semana ISO)
    // e o Sábado vira Domingo (fim da semana ISO).
    final shiftedDate = date.add(const Duration(days: 1));

    int dayOfWeek = shiftedDate.weekday; // 1 (Mon) .. 7 (Sun)
    DateTime thursday = shiftedDate.add(Duration(days: 4 - dayOfWeek));
    int year = thursday.year;

    DateTime firstThursday = DateTime(year, 1, 4);
    firstThursday = firstThursday.add(Duration(days: 4 - firstThursday.weekday));

    int weekNumber = 1 + ((thursday.difference(firstThursday).inDays) / 7).floor();

    return AppWeek(year, weekNumber);
  }
}
