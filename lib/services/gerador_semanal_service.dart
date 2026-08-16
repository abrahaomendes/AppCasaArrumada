import '../database/dao/tarefa_dao.dart';
import '../database/dao/execucao_dao.dart';
import '../models/execucao_tarefa.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/week_calculator.dart';

class GeradorSemanalService {
  final TarefaDao _tarefaDao = TarefaDao();
  final ExecucaoDao _execucaoDao = ExecucaoDao();

  /// Garante que todas as tarefas recorrentes ativas para a semana a qual a `dataReferencia` pertence
  /// (e também para a próxima semana) tenham sido instanciadas na tabela `execucoes_tarefas`.
  Future<void> gerarExecucoesParaSemana(DateTime dataReferencia) async {
    final diasSemana = AppDateUtils.getWeekDays(dataReferencia);

    for (final dia in diasSemana) {
      await gerarExecucoesParaDia(dia);
    }

    // Pré-gera a semana seguinte para manter a continuidade automática das tarefas
    final proximaSemana = AppDateUtils.getWeekDays(dataReferencia.add(const Duration(days: 7)));
    for (final dia in proximaSemana) {
      await gerarExecucoesParaDia(dia);
    }
  }

  /// Garante as execuções de um dia específico
  Future<void> gerarExecucoesParaDia(DateTime dia) async {
    final diaSemanaIso = dia.weekday; // 1 (Segunda) .. 7 (Domingo)
    final dataIso = AppDateUtils.formatDateToIso(dia);
    final appWeek = WeekCalculator.getAppWeek(dia);

    final tarefasRecorrentes = await _tarefaDao.getByDiaSemana(diaSemanaIso);

    for (final tarefa in tarefasRecorrentes) {
      // Verifica a semana de criação da tarefa
      final dataCriacao = DateTime.tryParse(tarefa.createdAt) ?? DateTime.now();
      final semanaCriacao = WeekCalculator.getAppWeek(dataCriacao);

      // Permite a geração se a data for na mesma semana da criação ou em semanas posteriores
      final bool pertenceASemanaAtualOuFutura =
          (appWeek.year > semanaCriacao.year) ||
          (appWeek.year == semanaCriacao.year && appWeek.week >= semanaCriacao.week) ||
          (dataIso.compareTo(tarefa.createdAt.substring(0, 10)) >= 0);

      if (!pertenceASemanaAtualOuFutura) {
        continue;
      }

      final jaExiste = await _execucaoDao.existeExecucaoParaTarefaEData(
        tarefa.id!,
        dataIso,
      );

      if (!jaExiste) {
        final novaExecucao = ExecucaoTarefa(
          tarefaId: tarefa.id,
          pessoaId: tarefa.pessoaId,
          descricao: tarefa.descricao,
          data: dataIso,
          semana: appWeek.week,
          ano: appWeek.year,
          status: ExecucaoStatus.pendente,
          isExtra: false,
          createdAt: DateTime.now().toIso8601String(),
        );

        await _execucaoDao.insert(novaExecucao);
      }
    }
  }
}
