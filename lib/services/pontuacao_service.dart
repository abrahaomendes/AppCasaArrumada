import '../database/app_database.dart';
import '../database/dao/execucao_dao.dart';
import '../database/dao/pontuacao_dao.dart';
import '../models/execucao_tarefa.dart';
import '../models/pontuacao_evento.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/week_calculator.dart';

class PontuacaoService {
  final ExecucaoDao _execucaoDao = ExecucaoDao();
  final PontuacaoDao _pontuacaoDao = PontuacaoDao();

  /// Conclui uma tarefa normal (+1 ponto) de forma atômica e idônea.
  Future<bool> concluirTarefaNormal(int execucaoId) async {
    final db = await AppDatabase.instance;

    return await db.transaction((txn) async {
      final execucao = await _execucaoDao.getById(execucaoId, txn: txn);
      if (execucao == null || execucao.status == ExecucaoStatus.concluida) {
        return false; // Já concluída ou inexistente
      }

      final jaTemEvento = await _pontuacaoDao.jaPossuiEvento(execucaoId, txn: txn);
      if (jaTemEvento) {
        return false; // Garantia adicional de idempotência
      }

      final agora = DateTime.now().toIso8601String();

      // 1. Atualiza status para CONCLUIDA
      await _execucaoDao.updateStatus(
        execucaoId,
        ExecucaoStatus.concluida,
        agora,
        txn: txn,
      );

      // 2. Insere evento de pontuação (+1)
      final evento = PontuacaoEvento(
        pessoaId: execucao.pessoaId,
        execucaoTarefaId: execucaoId,
        tipo: PontuacaoTipo.feliz,
        pontos: 1,
        data: agora,
      );

      await _pontuacaoDao.insert(evento, txn: txn);
      return true;
    });
  }

  Future<bool> desfazerConclusaoTarefa(int execucaoId) async {
    final db = await AppDatabase.instance;

    return await db.transaction((txn) async {
      final execucao = await _execucaoDao.getById(execucaoId, txn: txn);
      if (execucao == null || execucao.status != ExecucaoStatus.concluida) {
        return false;
      }

      // 1. Remove evento de pontuação se houver
      await _pontuacaoDao.deleteByExecucaoId(execucaoId, txn: txn);

      // 2. Atualiza status de volta para PENDENTE e remove completed_at
      await _execucaoDao.updateStatus(
        execucaoId,
        ExecucaoStatus.pendente,
        null,
        txn: txn,
      );

      return true;
    });
  }

  /// Adiciona uma Tarefa Extra (+2 pontos) criada diretamente como CONCLUIDA.
  Future<ExecucaoTarefa> adicionarTarefaExtra({
    required int pessoaId,
    required String descricao,
    DateTime? dataReferencia,
  }) async {
    final db = await AppDatabase.instance;
    final dataUsar = dataReferencia ?? DateTime.now();
    final dataIso = AppDateUtils.formatDateToIso(dataUsar);
    final appWeek = WeekCalculator.getAppWeek(dataUsar);
    final agora = DateTime.now().toIso8601String();

    return await db.transaction((txn) async {
      final novaExecucao = ExecucaoTarefa(
        tarefaId: null,
        pessoaId: pessoaId,
        descricao: descricao,
        data: dataIso,
        semana: appWeek.week,
        ano: appWeek.year,
        status: ExecucaoStatus.concluida,
        isExtra: true,
        createdAt: agora,
        completedAt: agora,
      );

      final idGerado = await _execucaoDao.insert(novaExecucao, txn: txn);

      final eventoExtra = PontuacaoEvento(
        pessoaId: pessoaId,
        execucaoTarefaId: idGerado,
        tipo: PontuacaoTipo.feliz,
        pontos: 2,
        data: agora,
      );

      await _pontuacaoDao.insert(eventoExtra, txn: txn);

      return novaExecucao.copyWith(id: idGerado);
    });
  }

  /// Remove uma Tarefa Extra e seus pontos associados.
  Future<bool> removerTarefaExtra(int execucaoId) async {
    final execucao = await _execucaoDao.getById(execucaoId);
    if (execucao == null || !execucao.isExtra) return false;

    final db = await AppDatabase.instance;
    return await db.transaction((txn) async {
      await _execucaoDao.delete(execucaoId, txn: txn);
      // Os pontos serão apagados automaticamente via ON DELETE CASCADE no banco de dados.
      return true;
    });
  }
}
