class ExecucaoStatus {
  static const String pendente = 'PENDENTE';
  static const String concluida = 'CONCLUIDA';
  static const String naoConcluida = 'NAO_CONCLUIDA';
}

class ExecucaoTarefa {
  final int? id;
  final int? tarefaId; // NULL se for tarefa extra
  final int pessoaId;
  final String descricao;
  final String data; // YYYY-MM-DD
  final int semana; // ISO Week number
  final int ano; // ISO Year
  final String status; // PENDENTE, CONCLUIDA, NAO_CONCLUIDA
  final bool isExtra; // false = Normal (+1), true = Extra (+2)
  final String createdAt;
  final String? completedAt;

  ExecucaoTarefa({
    this.id,
    this.tarefaId,
    required this.pessoaId,
    required this.descricao,
    required this.data,
    required this.semana,
    required this.ano,
    required this.status,
    this.isExtra = false,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tarefa_id': tarefaId,
      'pessoa_id': pessoaId,
      'descricao': descricao,
      'data': data,
      'semana': semana,
      'ano': ano,
      'status': status,
      'is_extra': isExtra ? 1 : 0,
      'created_at': createdAt,
      'completed_at': completedAt,
    };
  }

  factory ExecucaoTarefa.fromMap(Map<String, dynamic> map) {
    return ExecucaoTarefa(
      id: map['id'] as int?,
      tarefaId: map['tarefa_id'] as int?,
      pessoaId: map['pessoa_id'] as int,
      descricao: map['descricao'] as String,
      data: map['data'] as String,
      semana: map['semana'] as int,
      ano: map['ano'] as int,
      status: map['status'] as String,
      isExtra: (map['is_extra'] as int) == 1,
      createdAt: map['created_at'] as String,
      completedAt: map['completed_at'] as String?,
    );
  }

  ExecucaoTarefa copyWith({
    int? id,
    int? tarefaId,
    int? pessoaId,
    String? descricao,
    String? data,
    int? semana,
    int? ano,
    String? status,
    bool? isExtra,
    String? createdAt,
    String? completedAt,
  }) {
    return ExecucaoTarefa(
      id: id ?? this.id,
      tarefaId: tarefaId ?? this.tarefaId,
      pessoaId: pessoaId ?? this.pessoaId,
      descricao: descricao ?? this.descricao,
      data: data ?? this.data,
      semana: semana ?? this.semana,
      ano: ano ?? this.ano,
      status: status ?? this.status,
      isExtra: isExtra ?? this.isExtra,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
