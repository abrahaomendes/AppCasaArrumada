import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tarefa_provider.dart';
import '../../providers/pessoa_provider.dart';
import '../../providers/execucao_provider.dart';
import '../../models/tarefa.dart';
import '../../models/pessoa.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import 'tarefa_form_dialog.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TarefaProvider>().carregarTarefas();
      context.read<PessoaProvider>().carregarPessoas();
    });
  }

  void _abrirModalTarefa([Tarefa? tarefa]) async {
    final pessoas = context.read<PessoaProvider>().pessoas;

    if (pessoas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre pelo menos uma pessoa antes de criar tarefas recorrentes.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final dados = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => TarefaFormDialog(
        tarefaParaEditar: tarefa,
        pessoas: pessoas,
      ),
    );

    if (dados != null && mounted) {
      final provider = context.read<TarefaProvider>();
      await provider.salvarTarefa(
        id: tarefa?.id,
        descricao: dados['descricao'],
        diaSemana: dados['diaSemana'],
        pessoaId: dados['pessoaId'],
      );

      if (mounted) {
        context.read<ExecucaoProvider>().inicializarECarregar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarefa recorrente salva com sucesso!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tProvider = context.watch<TarefaProvider>();
    final pProvider = context.watch<PessoaProvider>();

    Map<int, Pessoa> mapaPessoas = {
      for (var p in pProvider.pessoas) p.id!: p
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas Recorrentes'),
      ),
      body: tProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : tProvider.tarefas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.repeat, size: 64, color: AppColors.textSecondary),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhuma tarefa recorrente',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Nova Tarefa'),
                        onPressed: () => _abrirModalTarefa(),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tProvider.tarefas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tProvider.tarefas[index];
                    final pessoa = mapaPessoas[tarefa.pessoaId];
                    final nomePessoa = pessoa?.nome ?? 'Desconhecido';
                    final avatar = (pessoa?.avatar != null && pessoa!.avatar!.isNotEmpty) ? '${pessoa.avatar} ' : '';
                    final nomeDia = AppDateUtils.getDayNamePtBr(tarefa.diaSemana);

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Icon(
                            _getIconForDay(tarefa.diaSemana),
                            color: AppColors.primary,
                          ),
                        ),
                        title: Text(
                          tarefa.descricao,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text('$nomeDia • Responsável: $avatar$nomePessoa'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppColors.textSecondary),
                              onPressed: () => _abrirModalTarefa(tarefa),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppColors.danger),
                              onPressed: () async {
                                await tProvider.desativarOuRemoverTarefa(tarefa.id!);
                                if (mounted) {
                                  context.read<ExecucaoProvider>().inicializarECarregar();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirModalTarefa(),
        tooltip: 'Criar Tarefa Recorrente',
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIconForDay(int day) {
    switch (day) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      case 4:
        return Icons.looks_4;
      case 5:
        return Icons.looks_5;
      case 6:
        return Icons.looks_6;
      case 7:
        return Icons.event;
      default:
        return Icons.task;
    }
  }
}
