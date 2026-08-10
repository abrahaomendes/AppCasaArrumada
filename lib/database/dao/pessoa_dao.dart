import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/pessoa.dart';

class PessoaDao {
  Future<int> insert(Pessoa pessoa) async {
    final db = await AppDatabase.instance;
    return await db.insert('pessoas', pessoa.toMap());
  }

  Future<int> update(Pessoa pessoa) async {
    final db = await AppDatabase.instance;
    return await db.update(
      'pessoas',
      pessoa.toMap(),
      where: 'id = ?',
      whereArgs: [pessoa.id],
    );
  }

  Future<List<Pessoa>> getAll({bool includeInactives = false}) async {
    final db = await AppDatabase.instance;
    final List<Map<String, dynamic>> maps;

    if (includeInactives) {
      maps = await db.query('pessoas', orderBy: 'nome ASC');
    } else {
      maps = await db.query(
        'pessoas',
        where: 'ativo = 1',
        orderBy: 'nome ASC',
      );
    }

    return maps.map((map) => Pessoa.fromMap(map)).toList();
  }

  Future<Pessoa?> getById(int id) async {
    final db = await AppDatabase.instance;
    final maps = await db.query('pessoas', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Pessoa.fromMap(maps.first);
  }

  /// Exclusão segura: se a pessoa possuir qualquer histórico de execução ou pontuação,
  /// faz desativação (soft delete ativo = 0) para preservar o histórico.
  Future<void> deleteOrDeactivate(int pessoaId) async {
    final db = await AppDatabase.instance;

    final execCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM execucoes_tarefas WHERE pessoa_id = ?',
          [pessoaId],
        )) ??
        0;

    final pointsCount = Sqflite.firstIntValue(await db.rawQuery(
          'SELECT COUNT(*) FROM pontuacao_eventos WHERE pessoa_id = ?',
          [pessoaId],
        )) ??
        0;

    if (execCount > 0 || pointsCount > 0) {
      // Soft delete para manter a integridade dos dados e rankings passados
      await db.update(
        'pessoas',
        {'ativo': 0},
        where: 'id = ?',
        whereArgs: [pessoaId],
      );
    } else {
      // Desativa tarefas vinculadas e depois exclui a pessoa
      await db.delete('tarefas', where: 'pessoa_id = ?', whereArgs: [pessoaId]);
      await db.delete('pessoas', where: 'id = ?', whereArgs: [pessoaId]);
    }
  }
}
