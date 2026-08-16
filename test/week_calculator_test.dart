import 'package:flutter_test/flutter_test.dart';
import 'package:casa_em_ordem/core/utils/week_calculator.dart';
import 'package:casa_em_ordem/core/utils/date_utils.dart';

void main() {
  group('WeekCalculator Tests', () {
    test('AppWeek is correct', () {
      final date = DateTime(2026, 8, 12);
      final appWeek = WeekCalculator.getAppWeek(date);
      expect(appWeek.year, 2026);
    });

    test('Identifica nomes de dias em português corretamente', () {
      expect(AppDateUtils.getDayNamePtBr(1), equals('Segunda-feira'));
      expect(AppDateUtils.getDayNamePtBr(7), equals('Domingo'));
    });

    test('Retorna os 7 dias da semana a partir de uma data de referência', () {
      final ref = DateTime(2026, 8, 5); // Quarta-feira
      final dias = AppDateUtils.getWeekDays(ref);

      expect(dias.length, equals(7));
      expect(dias.first.weekday, equals(7)); // Domingo
      expect(dias.last.weekday, equals(6)); // Sábado
    });
  });
}
