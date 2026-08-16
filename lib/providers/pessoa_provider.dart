import 'package:flutter/material.dart';
import '../repositories/pessoa_repository.dart';
import '../database/dao/pontuacao_dao.dart';
import '../core/utils/week_calculator.dart';
import '../models/pessoa.dart';

class PessoaProvider extends ChangeNotifier {
  final PessoaRepository _repository = PessoaRepository();
  final PontuacaoDao _pontuacaoDao = PontuacaoDao();

  List<Pessoa> _pessoas = [];
  bool _isLoading = false;
  int? _vencedorSemanaAnteriorId;

  List<Pessoa> get pessoas => _pessoas;
  bool get isLoading => _isLoading;
  int? get vencedorSemanaAnteriorId => _vencedorSemanaAnteriorId;

  Future<void> carregarPessoas() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pessoas = await _repository.getPessoas();
      
      final hoje = DateTime.now();
      final semanaAtual = WeekCalculator.getAppWeek(hoje);
      final anoAnterior = semanaAtual.week == 1 ? semanaAtual.year - 1 : semanaAtual.year;
      final semanaAnterior = semanaAtual.week == 1 ? 52 : semanaAtual.week - 1;
      
      final rankingAnterior = await _pontuacaoDao.getRankingSemanal(semanaAnterior, anoAnterior);
      if (rankingAnterior.isNotEmpty && rankingAnterior.first.totalPontos > 0) {
        _vencedorSemanaAnteriorId = rankingAnterior.first.pessoaId;
      } else {
        _vencedorSemanaAnteriorId = null;
      }
    } catch (e) {
      debugPrint('Erro carregarPessoas: \$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> adicionarOuAtualizarPessoa(String nome, {int? id, String? avatar, String? pedidoSemana}) async {
    try {
      final agora = DateTime.now().toIso8601String();
      final pessoa = Pessoa(
        id: id,
        nome: nome.trim(),
        avatar: avatar,
        pedidoSemana: pedidoSemana,
        createdAt: agora,
      );

      await _repository.salvarPessoa(pessoa);
      await carregarPessoas();
      return true;
    } catch (e, stack) {
      debugPrint('Erro em adicionarOuAtualizarPessoa: $e\n$stack');
      rethrow;
    }
  }

  Future<bool> removerPessoa(int id) async {
    try {
      await _repository.removerPessoa(id);
      await carregarPessoas();
      return true;
    } catch (e, stack) {
      debugPrint('Erro em removerPessoa: $e\n$stack');
      rethrow;
    }
  }
}
