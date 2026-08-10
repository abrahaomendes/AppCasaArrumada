import 'package:flutter/material.dart';
import '../models/execucao_tarefa.dart';
import '../models/pessoa.dart';
import '../database/dao/execucao_dao.dart';
import '../repositories/pessoa_repository.dart';
import '../services/gerador_semanal_service.dart';
import '../services/pontuacao_service.dart';
import '../services/fechamento_service.dart';
import '../core/utils/date_utils.dart';

class PessoaExecucoesGroup {
  final Pessoa pessoa;
  final List<ExecucaoTarefa> execucoes;

  PessoaExecucoesGroup({
    required this.pessoa,
    required this.execucoes,
  });
}

class ExecucaoProvider extends ChangeNotifier {
  final ExecucaoDao _execucaoDao = ExecucaoDao();
  final PessoaRepository _pessoaRepository = PessoaRepository();
  final GeradorSemanalService _geradorService = GeradorSemanalService();
  final PontuacaoService _pontuacaoService = PontuacaoService();
  final FechamentoService _fechamentoService = FechamentoService();

  DateTime _dataSelecionada = DateTime.now();
  List<PessoaExecucoesGroup> _grupos = [];
  bool _isLoading = false;

  DateTime get dataSelecionada => _dataSelecionada;
  List<PessoaExecucoesGroup> get grupos => _grupos;
  bool get isLoading => _isLoading;

  List<DateTime> get diasDaSemanaAtual => AppDateUtils.getWeekDays(_dataSelecionada);

  Future<void> inicializarECarregar() async {
    _isLoading = true;
    notifyListeners();

    // 1. Executa o fechamento diário de tarefas pendentes atrasadas
    await _fechamentoService.processarFechamentoDiario();

    // 2. Garante a geração das tarefas da semana selecionada
    await _geradorService.gerarExecucoesParaSemana(_dataSelecionada);

    // 3. Carrega e agrupa as tarefas do dia selecionado
    await _carregarExecucoesDoDia();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selecionarData(DateTime novaData) async {
    _dataSelecionada = novaData;
    await inicializarECarregar();
  }

  Future<void> _carregarExecucoesDoDia() async {
    final dataIso = AppDateUtils.formatDateToIso(_dataSelecionada);
    final execucoesDoDia = await _execucaoDao.getByData(dataIso);
    final todasPessoas = await _pessoaRepository.getPessoas(includeInactives: true);

    // Agrupa por pessoa
    Map<int, List<ExecucaoTarefa>> mapa = {};
    for (var exec in execucoesDoDia) {
      mapa.putIfAbsent(exec.pessoaId, () => []).add(exec);
    }

    List<PessoaExecucoesGroup> novosGrupos = [];

    // Inclui pessoas que têm execuções no dia ou estão ativas
    for (var pessoa in todasPessoas) {
      if (pessoa.id != null && (mapa.containsKey(pessoa.id) || pessoa.ativo)) {
        novosGrupos.add(PessoaExecucoesGroup(
          pessoa: pessoa,
          execucoes: mapa[pessoa.id] ?? [],
        ));
      }
    }

    _grupos = novosGrupos;
  }

  Future<bool> concluirTarefa(int execucaoId) async {
    final sucesso = await _pontuacaoService.concluirTarefaNormal(execucaoId);
    if (sucesso) {
      await _carregarExecucoesDoDia();
      notifyListeners();
    }
    return sucesso;
  }

  Future<void> adicionarTarefaExtra({
    required int pessoaId,
    required String descricao,
  }) async {
    await _pontuacaoService.adicionarTarefaExtra(
      pessoaId: pessoaId,
      descricao: descricao,
      dataReferencia: _dataSelecionada,
    );
    await _carregarExecucoesDoDia();
    notifyListeners();
  }
}
