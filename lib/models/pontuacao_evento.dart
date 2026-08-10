class PontuacaoTipo {
  static const String feliz = 'FELIZ';
  static const String infeliz = 'INFELIZ';
}

class PontuacaoEvento {
  final int? id;
  final int pessoaId;
  final int execucaoTarefaId;
  final String tipo; // FELIZ ou INFELIZ
  final int pontos; // +1, -1, ou +2
  final String data; // ISO Timestamp

  PontuacaoEvento({
    this.id,
    required this.pessoaId,
    required this.execucaoTarefaId,
    required this.tipo,
    required this.pontos,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'pessoa_id': pessoaId,
      'execucao_tarefa_id': execucaoTarefaId,
      'tipo': tipo,
      'pontos': pontos,
      'data': data,
    };
  }

  factory PontuacaoEvento.fromMap(Map<String, dynamic> map) {
    return PontuacaoEvento(
      id: map['id'] as int?,
      pessoaId: map['pessoa_id'] as int,
      execucaoTarefaId: map['execucao_tarefa_id'] as int,
      tipo: map['tipo'] as String,
      pontos: map['pontos'] as int,
      data: map['data'] as String,
    );
  }
}
