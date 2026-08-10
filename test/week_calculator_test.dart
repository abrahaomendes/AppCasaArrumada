import 'package:flutter_test/flutter_test.dart';
import 'package:casa_em_ordem/core/utils/week_calculator.dart';
import 'package:casa_em_ordem/core/utils/date_utils.dart';

void main() {
  group('WeekCalculator Tests', () {
    test('Calcula corretamente o número da semana ISO', () {
      final date = DateTime(2026, 8, 3); // Segunda-feira, 3 de agosto de 2026
      final isoWeek = WeekCalculator.getIsoWeek(date);

      expect(isoWeek.week, equals(32));
      expect(isoWeek.year, equals(2026));
      expect(isoWeek.toString(), equals('Semana 32 / 2026'));
    });

    test('Identifica nomes de dias em português corretamente', () {
      expect(AppDateUtils.getDayNamePtBr(1), equals('Segunda-feira'));
      expect(AppDateUtils.getDayNamePtBr(7), equals('Domingo'));
    });

    test('Retorna os 7 dias da semana a partir de uma data de referência', () {
      final ref = DateTime(2026, 8, 5); // Quarta-feira
      final dias = AppDateUtils.getWeekDays(ref);

      expect(dias.length, equals(7));
      expect(dias.first.weekday, equals(1)); // Segunda
      expect(dias.last.weekday, equals(7)); // Domingo
    });
  });
}
