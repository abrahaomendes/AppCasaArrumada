import 'package:flutter/material.dart';
import '../database/dao/tarefa_base_dao.dart';
import '../models/tarefa.dart';
import '../models/tarefa_base.dart';
import '../repositories/tarefa_repository.dart';

class TarefaProvider extends ChangeNotifier {
  final TarefaRepository _repository = TarefaRepository();
  final TarefaBaseDao _tarefaBaseDao = TarefaBaseDao();

  List<Tarefa> _tarefas = [];
  List<TarefaBase> _tarefasBase = [];
  bool _isLoading = false;

  List<Tarefa> get tarefas => _tarefas;
  List<TarefaBase> get tarefasBase => _tarefasBase;
  bool get isLoading => _isLoading;

  Future<void> carregarTarefas() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tarefas = await _repository.getTarefasAtivas();
      _tarefasBase = await _tarefaBaseDao.getAll();
    } catch (e) {
      debugPrint('Erro carregarTarefas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> salvarTarefaBase(String descricao, {int? id}) async {
    final agora = DateTime.now().toIso8601String();
    
    if (id != null) {
      final baseList = _tarefasBase.where((element) => element.id == id).toList();
      if (baseList.isNotEmpty) {
        final atualizada = baseList.first.copyWith(descricao: descricao.trim());
        await _tarefaBaseDao.update(atualizada);
      }
    } else {
      final base = TarefaBase(descricao: descricao.trim(), createdAt: agora);
      await _tarefaBaseDao.insert(base);
    }
    
    await carregarTarefas();
  }

  Future<void> excluirTarefaBase(int id) async {
    try {
      await _tarefaBaseDao.delete(id);
      await carregarTarefas();
    } catch (e) {
      throw Exception('Não é possível excluir uma tarefa base que já possui vínculos ativos.');
    }
  }

  Future<void> salvarTarefa({
    int? id,
    required int tarefaBaseId,
    required int diaSemana,
    required int pessoaId,
    int pontuacao = 1,
  }) async {
    String createdAtDate = DateTime.now().toIso8601String();
    if (id != null) {
      final existente = _tarefas.where((t) => t.id == id).toList();
      if (existente.isNotEmpty) {
        createdAtDate = existente.first.createdAt;
      }
    }

    final tarefa = Tarefa(
      id: id,
      tarefaBaseId: tarefaBaseId,
      diaSemana: diaSemana,
      pessoaId: pessoaId,
      pontuacao: pontuacao,
      ativa: true,
      createdAt: createdAtDate,
    );

    try {
      await _repository.salvarTarefa(tarefa);
      await carregarTarefas();
    } catch (e) {
      if (e.toString().contains('UNIQUE constraint failed')) {
        throw Exception('Esta tarefa já está vinculada para este dia da semana!');
      }
      rethrow;
    }
  }

  Future<void> desativarOuRemoverTarefa(int id) async {
    await _repository.removerTarefa(id);
    await carregarTarefas();
  }
}
