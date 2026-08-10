import '../database/app_database.dart';
import '../database/dao/execucao_dao.dart';
import '../database/dao/pontuacao_dao.dart';
import '../models/execucao_tarefa.dart';
import '../models/pontuacao_evento.dart';
import '../core/utils/date_utils.dart';

class FechamentoService {
  final ExecucaoDao _execucaoDao = ExecucaoDao();
  final PontuacaoDao _pontuacaoDao = PontuacaoDao();

  /// Executa a rotina de fechamento diário.
  /// Busca todas as tarefas normais com `data < hoje` que ainda estejam `PENDENTE`
  /// e as marca como `NAO_CONCLUIDA`, registrando o evento de `-1` ponto (INFELIZ).
  Future<int> processarFechamentoDiario() async {
    final hojeIso = AppDateUtils.formatDateToIso(DateTime.now());
    final pendentesAtrasadas = await _execucaoDao.getPendentesAnterioresA(hojeIso);

    if (pendentesAtrasadas.isEmpty) return 0;

    final db = await AppDatabase.instance;
    int processadas = 0;

    for (final exec in pendentesAtrasadas) {
      if (exec.id == null) continue;

      try {
        await db.transaction((txn) async {
          final jaTemEvento = await _pontuacaoDao.jaPossuiEvento(exec.id!, txn: txn);
          if (jaTemEvento) return;

          final agora = DateTime.now().toIso8601String();

          // 1. Marca como NAO_CONCLUIDA
          await _execucaoDao.updateStatus(
            exec.id!,
            ExecucaoStatus.naoConcluida,
            agora,
            txn: txn,
          );

          // 2. Insere evento de pontuação (-1)
          final eventoInfeliz = PontuacaoEvento(
            pessoaId: exec.pessoaId,
            execucaoTarefaId: exec.id!,
            tipo: PontuacaoTipo.infeliz,
            pontos: -1,
            data: agora,
          );

          await _pontuacaoDao.insert(eventoInfeliz, txn: txn);
          processadas++;
        });
      } catch (e) {
        // Se a constraint UNIQUE impedir uma duplicata, a exceção é engolida com segurança
      }
    }

    return processadas;
  }
}
