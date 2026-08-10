import '../app_database.dart';
import '../../models/tarefa.dart';

class TarefaDao {
  Future<int> insert(Tarefa tarefa) async {
    final db = await AppDatabase.instance;
    return await db.insert('tarefas', tarefa.toMap());
  }

  Future<int> update(Tarefa tarefa) async {
    final db = await AppDatabase.instance;
    return await db.update(
      'tarefas',
      tarefa.toMap(),
      where: 'id = ?',
      whereArgs: [tarefa.id],
    );
  }

  Future<List<Tarefa>> getAllAtivas() async {
    final db = await AppDatabase.instance;
    final maps = await db.query(
      'tarefas',
      where: 'ativa = 1',
      orderBy: 'dia_semana ASC, descricao ASC',
    );
    return maps.map((map) => Tarefa.fromMap(map)).toList();
  }

  Future<List<Tarefa>> getByDiaSemana(int diaSemana) async {
    final db = await AppDatabase.instance;
    final maps = await db.query(
      'tarefas',
      where: 'dia_semana = ? AND ativa = 1',
      whereArgs: [diaSemana],
      orderBy: 'descricao ASC',
    );
    return maps.map((map) => Tarefa.fromMap(map)).toList();
  }

  Future<List<Tarefa>> getByPessoa(int pessoaId) async {
    final db = await AppDatabase.instance;
    final maps = await db.query(
      'tarefas',
      where: 'pessoa_id = ? AND ativa = 1',
      whereArgs: [pessoaId],
      orderBy: 'dia_semana ASC, descricao ASC',
    );
    return maps.map((map) => Tarefa.fromMap(map)).toList();
  }

  Future<int> toggleAtiva(int id, bool ativa) async {
    final db = await AppDatabase.instance;
    return await db.update(
      'tarefas',
      {'ativa': ativa ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance;
    return await db.delete(
      'tarefas',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
