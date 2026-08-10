import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _dbName = 'casa_em_ordem.db';
  static const int _dbVersion = 2;

  static Database? _database;

  static Future<Database> get instance async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    String path;

    if (kIsWeb) {
      // Na web, usa o nome do banco diretamente (IndexedDB)
      path = _dbName;
    } else {
      // No mobile/desktop, usa o diretório padrão do dispositivo
      final dbPath = await getDatabasesPath();
      path = join(dbPath, _dbName);
    }

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: kIsWeb
          ? null
          : (db) async {
              await db.execute('PRAGMA foreign_keys = ON');
            },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE pessoas ADD COLUMN avatar TEXT');
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pessoas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            avatar TEXT,
            ativo INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE tarefas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descricao TEXT NOT NULL,
            dia_semana INTEGER NOT NULL,
            pessoa_id INTEGER NOT NULL,
            pontuacao INTEGER NOT NULL DEFAULT 1,
            ativa INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL,
            FOREIGN KEY (pessoa_id) REFERENCES pessoas (id) ON DELETE RESTRICT
          )
        ''');

        await db.execute('''
          CREATE TABLE execucoes_tarefas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tarefa_id INTEGER,
            pessoa_id INTEGER NOT NULL,
            descricao TEXT NOT NULL,
            data TEXT NOT NULL,
            semana INTEGER NOT NULL,
            ano INTEGER NOT NULL,
            status TEXT NOT NULL,
            is_extra INTEGER NOT NULL DEFAULT 0,
            created_at TEXT NOT NULL,
            completed_at TEXT,
            FOREIGN KEY (tarefa_id) REFERENCES tarefas (id) ON DELETE SET NULL,
            FOREIGN KEY (pessoa_id) REFERENCES pessoas (id) ON DELETE RESTRICT
          )
        ''');

        await db.execute('''
          CREATE TABLE pontuacao_eventos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pessoa_id INTEGER NOT NULL,
            execucao_tarefa_id INTEGER NOT NULL UNIQUE,
            tipo TEXT NOT NULL,
            pontos INTEGER NOT NULL,
            data TEXT NOT NULL,
            FOREIGN KEY (pessoa_id) REFERENCES pessoas (id) ON DELETE RESTRICT,
            FOREIGN KEY (execucao_tarefa_id) REFERENCES execucoes_tarefas (id) ON DELETE CASCADE
          )
        ''');

        await db.execute(
            'CREATE INDEX idx_execucoes_data ON execucoes_tarefas(data)');
        await db.execute(
            'CREATE INDEX idx_execucoes_semana_ano ON execucoes_tarefas(semana, ano)');
        await db.execute(
            'CREATE INDEX idx_pontuacao_pessoa ON pontuacao_eventos(pessoa_id)');
      },
    );
  }

  static Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
