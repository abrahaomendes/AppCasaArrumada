import 'package:flutter/material.dart';
import '../repositories/tarefa_repository.dart';
import '../models/tarefa.dart';

class TarefaProvider extends ChangeNotifier {
  final TarefaRepository _repository = TarefaRepository();

  List<Tarefa> _tarefas = [];
  bool _isLoading = false;

  List<Tarefa> get tarefas => _tarefas;
  bool get isLoading => _isLoading;

  Future<void> carregarTarefas() async {
    _isLoading = true;
    notifyListeners();

    _tarefas = await _repository.getTarefasAtivas();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> salvarTarefa({
    int? id,
    required String descricao,
    required int diaSemana,
    required int pessoaId,
    int pontuacao = 1,
  }) async {
    final agora = DateTime.now().toIso8601String();
    final tarefa = Tarefa(
      id: id,
      descricao: descricao.trim(),
      diaSemana: diaSemana,
      pessoaId: pessoaId,
      pontuacao: pontuacao,
      ativa: true,
      createdAt: agora,
    );

    await _repository.salvarTarefa(tarefa);
    await carregarTarefas();
  }

  Future<void> desativarOuRemoverTarefa(int id) async {
    await _repository.removerTarefa(id);
    await carregarTarefas();
  }
}
