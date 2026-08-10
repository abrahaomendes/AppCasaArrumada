import 'package:flutter/material.dart';
import '../repositories/pessoa_repository.dart';
import '../models/pessoa.dart';

class PessoaProvider extends ChangeNotifier {
  final PessoaRepository _repository = PessoaRepository();

  List<Pessoa> _pessoas = [];
  bool _isLoading = false;

  List<Pessoa> get pessoas => _pessoas;
  bool get isLoading => _isLoading;

  Future<void> carregarPessoas() async {
    _isLoading = true;
    notifyListeners();

    _pessoas = await _repository.getPessoas();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> adicionarOuAtualizarPessoa(String nome, {int? id, String? avatar}) async {
    final agora = DateTime.now().toIso8601String();
    final pessoa = Pessoa(
      id: id,
      nome: nome.trim(),
      avatar: avatar,
      createdAt: agora,
    );

    await _repository.salvarPessoa(pessoa);
    await carregarPessoas();
  }

  Future<void> removerPessoa(int id) async {
    await _repository.removerPessoa(id);
    await carregarPessoas();
  }
}
