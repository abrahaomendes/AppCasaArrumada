import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/execucao_tarefa.dart';

class ExecucaoDao {
  Future<int> insert(ExecucaoTarefa execucao, {Transaction? txn}) async {
    final db = txn ?? await AppDatabase.instance;
    return await db.insert('execucoes_tarefas', execucao.toMap());
  }

  Future<List<ExecucaoTarefa>> getByData(String dataIso) async {
    final db = await AppDatabase.instance;
    final maps = await db.query(
      'execucoes_tarefas',
      where: 'data = ?',
      whereArgs: [dataIso],
      orderBy: 'pessoa_id ASC, id ASC',
    );
    return maps.map((map) => ExecucaoTarefa.fromMap(map)).toList();
  }

  Future<List<ExecucaoTarefa>> getBySemanaAno(int semana, int ano) async {
    final db = await AppDatabase.instance;
    final maps = await db.query(
      'execucoes_tarefas',
      where: 'semana = ? AND ano = ?',
      whereArgs: [semana, ano],
      orderBy: 'data ASC, pessoa_id ASC',
    );
    return maps.map((map) => ExecucaoTarefa.fromMap(map)).toList();
  }

  /// Busca tarefas pendentes em datas estritamente anteriores à data informada (para o FechamentoService)
  Future<List<ExecucaoTarefa>> getPendentesAnterioresA(String dataHojeIso) async {
    final db = await AppDatabase.instance;
    final maps = await db.query(
      'execucoes_tarefas',
      where: 'data < ? AND status = ?',
      whereArgs: [dataHojeIso, ExecucaoStatus.pendente],
    );
    return maps.map((map) => ExecucaoTarefa.fromMap(map)).toList();
  }

  Future<ExecucaoTarefa?> getById(int id, {Transaction? txn}) async {
    final db = txn ?? await AppDatabase.instance;
    final maps = await db.query(
      'execucoes_tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ExecucaoTarefa.fromMap(maps.first);
  }

  Future<int> updateStatus(int id, String status, String? completedAt, {Transaction? txn}) async {
    final db = txn ?? await AppDatabase.instance;
    return await db.update(
      'execucoes_tarefas',
      {
        'status': status,
        'completed_at': completedAt,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Verifica se já existe uma execução gerada para determinada tarefa recorrente em uma data específica
  Future<bool> existeExecucaoParaTarefaEData(int tarefaId, String dataIso) async {
    final db = await AppDatabase.instance;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM execucoes_tarefas WHERE tarefa_id = ? AND data = ?',
      [tarefaId, dataIso],
    ));
    return (count ?? 0) > 0;
  }

  Future<int> delete(int id, {Transaction? txn}) async {
    final db = txn ?? await AppDatabase.instance;
    await db.delete(
      'pontuacao_eventos',
      where: 'execucao_tarefa_id = ?',
      whereArgs: [id],
    );
    return await db.delete(
      'execucoes_tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Remove todas as execuções (e eventos de pontuação associados) vinculadas a uma tarefa recorrente
  Future<void> deleteByTarefaId(int tarefaId, {Transaction? txn}) async {
    final db = txn ?? await AppDatabase.instance;
    await db.execute('''
      DELETE FROM pontuacao_eventos 
      WHERE execucao_tarefa_id IN (
        SELECT id FROM execucoes_tarefas WHERE tarefa_id = ?
      )
    ''', [tarefaId]);

    await db.delete(
      'execucoes_tarefas',
      where: 'tarefa_id = ?',
      whereArgs: [tarefaId],
    );
  }
}
