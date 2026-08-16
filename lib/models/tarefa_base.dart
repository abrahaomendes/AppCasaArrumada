class TarefaBase {
  final int? id;
  final String descricao;
  final bool ativa;
  final String createdAt;

  TarefaBase({
    this.id,
    required this.descricao,
    this.ativa = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'descricao': descricao,
      'ativa': ativa ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory TarefaBase.fromMap(Map<String, dynamic> map) {
    return TarefaBase(
      id: map['id'] as int?,
      descricao: map['descricao'] as String,
      ativa: (map['ativa'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  TarefaBase copyWith({
    int? id,
    String? descricao,
    bool? ativa,
    String? createdAt,
  }) {
    return TarefaBase(
      id: id ?? this.id,
      descricao: descricao ?? this.descricao,
      ativa: ativa ?? this.ativa,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
