import 'package:flutter/material.dart';
import '../database/dao/pontuacao_dao.dart';
import '../core/utils/week_calculator.dart';

class RankingProvider extends ChangeNotifier {
  final PontuacaoDao _pontuacaoDao = PontuacaoDao();

  late AppWeek _semanaSelecionada;
  List<PontuacaoResumoPessoa> _ranking = [];
  bool _isLoading = false;

  RankingProvider() {
    _semanaSelecionada = WeekCalculator.getAppWeek(DateTime.now());
  }

  AppWeek get semanaSelecionada => _semanaSelecionada;
  List<PontuacaoResumoPessoa> get ranking => _ranking;
  bool get isLoading => _isLoading;

  Future<void> carregarRanking() async {
    _isLoading = true;
    notifyListeners();

    _ranking = await _pontuacaoDao.getRankingSemanal(
      _semanaSelecionada.week,
      _semanaSelecionada.year,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selecionarSemana(AppWeek novaSemana) async {
    _semanaSelecionada = novaSemana;
    await carregarRanking();
  }

  Future<void> semanaAnterior() async {
    final novaSemana = AppWeek(
      _semanaSelecionada.week == 1
          ? _semanaSelecionada.year - 1
          : _semanaSelecionada.year,
      _semanaSelecionada.week == 1 ? 52 : _semanaSelecionada.week - 1,
    );
    await selecionarSemana(novaSemana);
  }

  Future<void> semanaSeguinte() async {
    final novaSemana = AppWeek(
      _semanaSelecionada.week >= 52
          ? _semanaSelecionada.year + 1
          : _semanaSelecionada.year,
      _semanaSelecionada.week >= 52 ? 1 : _semanaSelecionada.week + 1,
    );
    await selecionarSemana(novaSemana);
  }
}
