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
    final maps = await db.rawQuery('''
      SELECT t.*, tb.descricao 
      FROM tarefas t
      JOIN tarefas_base tb ON t.tarefa_base_id = tb.id
      WHERE t.ativa = 1
      ORDER BY t.dia_semana ASC, tb.descricao ASC
    ''');
    return maps.map((map) => Tarefa.fromMap(map)).toList();
  }

  Future<List<Tarefa>> getByDiaSemana(int diaSemana) async {
    final db = await AppDatabase.instance;
    final maps = await db.rawQuery('''
      SELECT t.*, tb.descricao 
      FROM tarefas t
      JOIN tarefas_base tb ON t.tarefa_base_id = tb.id
      WHERE t.dia_semana = ? AND t.ativa = 1
      ORDER BY tb.descricao ASC
    ''', [diaSemana]);
    return maps.map((map) => Tarefa.fromMap(map)).toList();
  }

  Future<List<Tarefa>> getByPessoa(int pessoaId) async {
    final db = await AppDatabase.instance;
    final maps = await db.rawQuery('''
      SELECT t.*, tb.descricao 
      FROM tarefas t
      JOIN tarefas_base tb ON t.tarefa_base_id = tb.id
      WHERE t.pessoa_id = ? AND t.ativa = 1
      ORDER BY t.dia_semana ASC, tb.descricao ASC
    ''', [pessoaId]);
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
