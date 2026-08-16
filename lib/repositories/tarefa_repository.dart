import '../database/dao/tarefa_dao.dart';
import '../database/dao/execucao_dao.dart';
import '../models/tarefa.dart';

class TarefaRepository {
  final TarefaDao _tarefaDao = TarefaDao();
  final ExecucaoDao _execucaoDao = ExecucaoDao();

  Future<List<Tarefa>> getTarefasAtivas() {
    return _tarefaDao.getAllAtivas();
  }

  Future<List<Tarefa>> getTarefasPorDiaSemana(int diaSemana) {
    return _tarefaDao.getByDiaSemana(diaSemana);
  }

  Future<List<Tarefa>> getTarefasPorPessoa(int pessoaId) {
    return _tarefaDao.getByPessoa(pessoaId);
  }

  Future<int> salvarTarefa(Tarefa tarefa) {
    if (tarefa.id != null) {
      return _tarefaDao.update(tarefa);
    } else {
      return _tarefaDao.insert(tarefa);
    }
  }

  Future<int> toggleAtiva(int id, bool ativa) {
    return _tarefaDao.toggleAtiva(id, ativa);
  }

  Future<int> removerTarefa(int id) async {
    await _execucaoDao.deleteByTarefaId(id);
    return await _tarefaDao.delete(id);
  }
}
