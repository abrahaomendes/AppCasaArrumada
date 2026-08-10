class Pessoa {
  final int? id;
  final String nome;
  final String? avatar;
  final bool ativo;
  final String createdAt;

  Pessoa({
    this.id,
    required this.nome,
    this.avatar,
    this.ativo = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'avatar': avatar,
      'ativo': ativo ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Pessoa.fromMap(Map<String, dynamic> map) {
    return Pessoa(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      avatar: map['avatar'] as String?,
      ativo: (map['ativo'] as int) == 1,
      createdAt: map['created_at'] as String,
    );
  }

  Pessoa copyWith({
    int? id,
    String? nome,
    String? avatar,
    bool? ativo,
    String? createdAt,
  }) {
    return Pessoa(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      avatar: avatar ?? this.avatar,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
