import 'package:sqflite/sqflite.dart';
import '../../models/tarefa_base.dart';
import '../app_database.dart';

class TarefaBaseDao {
  static const String tableName = 'tarefas_base';

  Future<int> insert(TarefaBase tarefaBase) async {
    final db = await AppDatabase.instance;
    return await db.insert(tableName, tarefaBase.toMap());
  }

  Future<int> update(TarefaBase tarefaBase) async {
    final db = await AppDatabase.instance;
    return await db.update(
      tableName,
      tarefaBase.toMap(),
      where: 'id = ?',
      whereArgs: [tarefaBase.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance;
    return await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TarefaBase>> getAll({bool apenasAtivas = true}) async {
    final db = await AppDatabase.instance;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: apenasAtivas ? 'ativa = 1' : null,
      orderBy: 'descricao COLLATE NOCASE ASC',
    );
    return maps.map((e) => TarefaBase.fromMap(e)).toList();
  }

  Future<TarefaBase?> getById(int id) async {
    final db = await AppDatabase.instance;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return TarefaBase.fromMap(maps.first);
    }
    return null;
  }
}
