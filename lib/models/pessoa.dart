class Pessoa {
  final int? id;
  final String nome;
  final String? avatar;
  final String? pedidoSemana;
  final bool ativo;
  final String createdAt;

  Pessoa({
    this.id,
    required this.nome,
    this.avatar,
    this.pedidoSemana,
    this.ativo = true,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'avatar': avatar,
      'pedido_semana': pedidoSemana,
      'ativo': ativo ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Pessoa.fromMap(Map<String, dynamic> map) {
    final rawAtivo = map['ativo'];
    final bool isAtivo = rawAtivo == null
        ? true
        : (rawAtivo == 1 || rawAtivo == true || rawAtivo == '1');

    return Pessoa(
      id: map['id'] as int?,
      nome: (map['nome'] as String?) ?? '',
      avatar: map['avatar'] as String?,
      pedidoSemana: map['pedido_semana'] as String?,
      ativo: isAtivo,
      createdAt: (map['created_at'] as String?) ?? DateTime.now().toIso8601String(),
    );
  }

  Pessoa copyWith({
    int? id,
    String? nome,
    String? avatar,
    String? pedidoSemana,
    bool? ativo,
    String? createdAt,
  }) {
    return Pessoa(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      avatar: avatar ?? this.avatar,
      pedidoSemana: pedidoSemana ?? this.pedidoSemana,
      ativo: ativo ?? this.ativo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
