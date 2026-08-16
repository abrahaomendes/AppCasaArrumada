import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String _dbName = 'casa_em_ordem.db';
  static const int _dbVersion = 5;

  static Database? _database;
  static Future<Database>? _initDbFuture;

  static Future<Database> get instance {
    if (_database != null && _database!.isOpen) return Future.value(_database!);
    _initDbFuture ??= _initDatabase().then((db) {
      _database = db;
      return db;
    }).catchError((error) {
      _initDbFuture = null;
      throw error;
    });
    return _initDbFuture!;
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
        if (oldVersion < 3) {
          // 1. Criar tabela tarefas_base
          await db.execute('''
            CREATE TABLE tarefas_base (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              descricao TEXT NOT NULL UNIQUE,
              ativa INTEGER NOT NULL DEFAULT 1,
              created_at TEXT NOT NULL
            )
          ''');

          // 2. Inserir tarefas únicas em tarefas_base
          await db.execute('''
            INSERT INTO tarefas_base (descricao, created_at)
            SELECT DISTINCT descricao, min(created_at) FROM tarefas GROUP BY descricao
          ''');

          // 3. Adicionar coluna na tabela tarefas (allow null initially)
          await db.execute('ALTER TABLE tarefas ADD COLUMN tarefa_base_id INTEGER DEFAULT 0');

          // 4. Preencher tarefa_base_id
          await db.execute('''
            UPDATE tarefas 
            SET tarefa_base_id = (
              SELECT id FROM tarefas_base WHERE tarefas_base.descricao = tarefas.descricao
            )
          ''');

          // 5. Adicionar UNIQUE INDEX
          await db.execute('CREATE UNIQUE INDEX idx_tarefa_dia_semana ON tarefas(tarefa_base_id, dia_semana)');
        }
        if (oldVersion < 5) {
          try {
            await db.execute('ALTER TABLE pessoas ADD COLUMN pedido_semana TEXT');
          } catch (_) {
            // Ignorar se a coluna já existir (ex: quem tentou usar a v4 com defeito)
          }
        }
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE pessoas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            nome TEXT NOT NULL,
            avatar TEXT,
            pedido_semana TEXT,
            ativo INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE tarefas_base (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            descricao TEXT NOT NULL UNIQUE,
            ativa INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE tarefas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tarefa_base_id INTEGER NOT NULL,
            dia_semana INTEGER NOT NULL,
            pessoa_id INTEGER NOT NULL,
            pontuacao INTEGER NOT NULL DEFAULT 1,
            ativa INTEGER NOT NULL DEFAULT 1,
            created_at TEXT NOT NULL,
            FOREIGN KEY (tarefa_base_id) REFERENCES tarefas_base (id) ON DELETE RESTRICT,
            FOREIGN KEY (pessoa_id) REFERENCES pessoas (id) ON DELETE RESTRICT
          )
        ''');

        await db.execute('CREATE UNIQUE INDEX idx_tarefa_dia_semana ON tarefas(tarefa_base_id, dia_semana)');

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
