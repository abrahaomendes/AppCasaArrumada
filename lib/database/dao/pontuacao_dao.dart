import 'package:sqflite/sqflite.dart';
import '../app_database.dart';
import '../../models/pontuacao_evento.dart';

class PontuacaoResumoPessoa {
  final int pessoaId;
  final String nomePessoa;
  final String? avatar;
  final String? pedidoSemana;
  final int totalPontos;
  final int tarefasFelizes; // +1
  final int tarefasInfelizes; // -1
  final int tarefasExtras; // +2

  PontuacaoResumoPessoa({
    required this.pessoaId,
    required this.nomePessoa,
    this.avatar,
    this.pedidoSemana,
    required this.totalPontos,
    required this.tarefasFelizes,
    required this.tarefasInfelizes,
    required this.tarefasExtras,
  });
}

class PontuacaoDao {
  /// Insere evento de pontuação. Se a execução já tiver um evento gravado,
  /// o SQLite lançará DatabaseException por violação de UNIQUE(execucao_tarefa_id).
  Future<int> insert(PontuacaoEvento evento, {Transaction? txn}) async {
    final db = txn ?? await AppDatabase.instance;
    return await db.insert('pontuacao_eventos', evento.toMap());
  }

  Future<bool> jaPossuiEvento(int execucaoTarefaId, {Transaction? txn}) async {
    final db = txn ?? await AppDatabase.instance;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM pontuacao_eventos WHERE execucao_tarefa_id = ?',
      [execucaoTarefaId],
    ));
    return (count ?? 0) > 0;
  }

  Future<int> deleteByExecucaoId(int execucaoTarefaId, {Transaction? txn}) async {
    final db = txn ?? await AppDatabase.instance;
    return await db.delete(
      'pontuacao_eventos',
      where: 'execucao_tarefa_id = ?',
      whereArgs: [execucaoTarefaId],
    );
  }

  /// Calcula o ranking consolidado de uma determinada semana ISO (número da semana + ano)
  Future<List<PontuacaoResumoPessoa>> getRankingSemanal(int semana, int ano) async {
    final db = await AppDatabase.instance;

    final query = '''
      SELECT 
        p.id AS pessoa_id,
        p.nome AS nome_pessoa,
        p.avatar AS avatar,
        p.pedido_semana AS pedido_semana,
        COALESCE(SUM(pe.pontos), 0) AS total_pontos,
        COALESCE(SUM(CASE WHEN pe.pontos = 1 THEN 1 ELSE 0 END), 0) AS tarefas_felizes,
        COALESCE(SUM(CASE WHEN pe.pontos = -1 THEN 1 ELSE 0 END), 0) AS tarefas_infelizes,
        COALESCE(SUM(CASE WHEN pe.pontos = 2 THEN 1 ELSE 0 END), 0) AS tarefas_extras
      FROM pessoas p
      LEFT JOIN execucoes_tarefas et ON et.pessoa_id = p.id AND et.semana = ? AND et.ano = ?
      LEFT JOIN pontuacao_eventos pe ON pe.execucao_tarefa_id = et.id
      WHERE p.ativo = 1 OR et.id IS NOT NULL
      GROUP BY p.id, p.nome, p.avatar, p.pedido_semana
      ORDER BY total_pontos DESC, tarefas_felizes DESC, p.nome ASC
    ''';

    final result = await db.rawQuery(query, [semana, ano]);

    return result.map((row) {
      return PontuacaoResumoPessoa(
        pessoaId: row['pessoa_id'] as int,
        nomePessoa: row['nome_pessoa'] as String,
        avatar: row['avatar'] as String?,
        pedidoSemana: row['pedido_semana'] as String?,
        totalPontos: row['total_pontos'] as int,
        tarefasFelizes: row['tarefas_felizes'] as int,
        tarefasInfelizes: row['tarefas_infelizes'] as int,
        tarefasExtras: row['tarefas_extras'] as int,
      );
    }).toList();
  }

  /// Busca os estatísticas detalhadas de uma pessoa específica para uma determinada semana
  Future<PontuacaoResumoPessoa?> getResumoPessoaNaSemana(int pessoaId, int semana, int ano) async {
    final db = await AppDatabase.instance;

    final query = '''
      SELECT 
        p.id AS pessoa_id,
        p.nome AS nome_pessoa,
        p.avatar AS avatar,
        p.pedido_semana AS pedido_semana,
        COALESCE(SUM(pe.pontos), 0) AS total_pontos,
        COALESCE(SUM(CASE WHEN pe.pontos = 1 THEN 1 ELSE 0 END), 0) AS tarefas_felizes,
        COALESCE(SUM(CASE WHEN pe.pontos = -1 THEN 1 ELSE 0 END), 0) AS tarefas_infelizes,
        COALESCE(SUM(CASE WHEN pe.pontos = 2 THEN 1 ELSE 0 END), 0) AS tarefas_extras
      FROM pessoas p
      LEFT JOIN execucoes_tarefas et ON et.pessoa_id = p.id AND et.semana = ? AND et.ano = ?
      LEFT JOIN pontuacao_eventos pe ON pe.execucao_tarefa_id = et.id
      WHERE p.id = ?
      GROUP BY p.id, p.nome, p.avatar, p.pedido_semana
    ''';

    final result = await db.rawQuery(query, [semana, ano, pessoaId]);
    if (result.isEmpty) return null;

    final row = result.first;
    return PontuacaoResumoPessoa(
      pessoaId: row['pessoa_id'] as int,
      nomePessoa: row['nome_pessoa'] as String,
      avatar: row['avatar'] as String?,
      pedidoSemana: row['pedido_semana'] as String?,
      totalPontos: row['total_pontos'] as int,
      tarefasFelizes: row['tarefas_felizes'] as int,
      tarefasInfelizes: row['tarefas_infelizes'] as int,
      tarefasExtras: row['tarefas_extras'] as int,
    );
  }
}
