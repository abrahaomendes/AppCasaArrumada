import '../database/dao/pessoa_dao.dart';
import '../models/pessoa.dart';

class PessoaRepository {
  final PessoaDao _pessoaDao = PessoaDao();

  Future<List<Pessoa>> getPessoas({bool includeInactives = false}) {
    return _pessoaDao.getAll(includeInactives: includeInactives);
  }

  Future<Pessoa?> getPessoaById(int id) {
    return _pessoaDao.getById(id);
  }

  Future<int> salvarPessoa(Pessoa pessoa) {
    if (pessoa.id != null) {
      return _pessoaDao.update(pessoa);
    } else {
      return _pessoaDao.insert(pessoa);
    }
  }

  Future<void> removerPessoa(int pessoaId) {
    return _pessoaDao.deleteOrDeactivate(pessoaId);
  }
}
