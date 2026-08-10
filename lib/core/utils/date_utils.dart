import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDateToIso(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static DateTime parseIsoDate(String dateStr) {
    return DateTime.parse(dateStr);
  }

  static String getDayNamePtBr(int weekday) {
    switch (weekday) {
      case 1:
        return 'Segunda-feira';
      case 2:
        return 'Terça-feira';
      case 3:
        return 'Quarta-feira';
      case 4:
        return 'Quinta-feira';
      case 5:
        return 'Sexta-feira';
      case 6:
        return 'Sábado';
      case 7:
        return 'Domingo';
      default:
        return '';
    }
  }

  static String getShortDayNamePtBr(int weekday) {
    switch (weekday) {
      case 1:
        return 'Seg';
      case 2:
        return 'Ter';
      case 3:
        return 'Qua';
      case 4:
        return 'Qui';
      case 5:
        return 'Sex';
      case 6:
        return 'Sáb';
      case 7:
        return 'Dom';
      default:
        return '';
    }
  }

  static String formatDisplayDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final monthName = _getMonthNamePtBr(date.month);
    return '$day de $monthName';
  }

  static String _getMonthNamePtBr(int month) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return months[month - 1];
  }

  /// Retorna os 7 dias (Domingo a Sábado) da semana a qual a data pertence
  static List<DateTime> getWeekDays(DateTime referenceDate) {
    // weekday em Dart: 1 (Seg) a 7 (Dom)
    // Para Domingo (7), 7 % 7 = 0. Ou seja, se for Domingo, já é o primeiro dia.
    // Para Segunda (1), 1 % 7 = 1. Subtrai 1 dia e chega no Domingo.
    final sunday = referenceDate.subtract(Duration(days: referenceDate.weekday % 7));
    return List.generate(7, (i) => DateTime(sunday.year, sunday.month, sunday.day + i));
  }
}
