class Tarefa {
  final int? id;
  final int tarefaBaseId;
  final String descricao; // Trazido pelo JOIN (leitura)
  final int diaSemana; // 1 (Mon) .. 7 (Sun)
  final int pessoaId;
  final int pontuacao; // Padrão 1
  final bool ativa;
  final String createdAt;

  Tarefa({
    this.id,
    required this.tarefaBaseId,
    this.descricao = '', // Pode vir vazio se não for um JOIN
    required this.diaSemana,
    required this.pessoaId,
    this.pontuacao = 1,
    this.ativa = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tarefa_base_id': tarefaBaseId,
      'dia_semana': diaSemana,
      'pessoa_id': pessoaId,
      'pontuacao': pontuacao,
      'ativa': ativa ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Tarefa.fromMap(Map<String, dynamic> map) {
    return Tarefa(
      id: map['id'] as int?,
      tarefaBaseId: map['tarefa_base_id'] as int,
      descricao: map['descricao'] as String? ?? '',
      diaSemana: map['dia_semana'] as int,
      pessoaId: map['pessoa_id'] as int,
      pontuacao: map['pontuacao'] as int,
      ativa: (map['ativa'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  Tarefa copyWith({
    int? id,
    int? tarefaBaseId,
    String? descricao,
    int? diaSemana,
    int? pessoaId,
    int? pontuacao,
    bool? ativa,
    String? createdAt,
  }) {
    return Tarefa(
      id: id ?? this.id,
      tarefaBaseId: tarefaBaseId ?? this.tarefaBaseId,
      descricao: descricao ?? this.descricao,
      diaSemana: diaSemana ?? this.diaSemana,
      pessoaId: pessoaId ?? this.pessoaId,
      pontuacao: pontuacao ?? this.pontuacao,
      ativa: ativa ?? this.ativa,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
