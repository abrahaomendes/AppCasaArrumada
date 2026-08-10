import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pessoa_provider.dart';
import '../../providers/execucao_provider.dart';
import '../../models/pessoa.dart';
import '../../core/constants/app_colors.dart';
import 'pessoa_form_dialog.dart';

class PessoasScreen extends StatefulWidget {
  const PessoasScreen({super.key});

  @override
  State<PessoasScreen> createState() => _PessoasScreenState();
}

class _PessoasScreenState extends State<PessoasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PessoaProvider>().carregarPessoas();
    });
  }

  void _abrirModalPessoa([Pessoa? pessoa]) async {
    final dados = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => PessoaFormDialog(pessoaParaEditar: pessoa),
    );

    if (dados != null && mounted) {
      final provider = context.read<PessoaProvider>();
      await provider.adicionarOuAtualizarPessoa(
        dados['nome'],
        id: pessoa?.id,
        avatar: dados['avatar'],
      );
      if (mounted) {
        context.read<ExecucaoProvider>().inicializarECarregar();
      }
    }
  }

  void _confirmarExclusao(Pessoa pessoa) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Pessoa?'),
        content: Text(
          'Deseja remover "${pessoa.nome}"? Seu histórico de pontuações e conquistas passadas será preservado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<PessoaProvider>().removerPessoa(pessoa.id!);
              if (mounted) {
                context.read<ExecucaoProvider>().inicializarECarregar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pessoa "${pessoa.nome}" removida.')),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PessoaProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pessoas'),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.pessoas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline,
                          size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhuma pessoa cadastrada',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Adicionar Pessoa'),
                        onPressed: () => _abrirModalPessoa(),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.pessoas.length,
                  itemBuilder: (context, index) {
                    final pessoa = provider.pessoas[index];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                          child: pessoa.avatar != null && pessoa.avatar!.isNotEmpty
                              ? Text(
                                  pessoa.avatar!,
                                  style: const TextStyle(fontSize: 24),
                                )
                              : Text(
                                  pessoa.nome[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                        ),
                        title: Text(
                          pessoa.nome,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppColors.textSecondary),
                              onPressed: () => _abrirModalPessoa(pessoa),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                              onPressed: () => _confirmarExclusao(pessoa),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirModalPessoa(),
        tooltip: 'Adicionar Pessoa',
        child: const Icon(Icons.add),
      ),
    );
  }
}
