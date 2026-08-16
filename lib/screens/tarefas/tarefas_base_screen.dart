import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/tarefa_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/error_helper.dart';

class TarefasBaseScreen extends StatelessWidget {
  const TarefasBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TarefaProvider>();
    final tarefasBase = provider.tarefasBase;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas da Casa'),
      ),
      body: tarefasBase.isEmpty
          ? const Center(child: Text('Nenhuma tarefa cadastrada. Crie uma!'))
          : ListView.builder(
              itemCount: tarefasBase.length,
              itemBuilder: (context, index) {
                final tb = tarefasBase[index];
                return ListTile(
                  title: Text(tb.descricao),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
                        onPressed: () => _abrirModalTarefaBase(context, tarefaBase: tb),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                        onPressed: () => _confirmarExclusao(context, tb.id!, tb.descricao),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _abrirModalTarefaBase(context),
        tooltip: 'Nova Tarefa',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _abrirModalTarefaBase(BuildContext context, {dynamic tarefaBase}) {
    final isEditing = tarefaBase != null;
    final controller = TextEditingController(text: isEditing ? tarefaBase.descricao : '');
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa (Descrição)'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Ex: Tirar o lixo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                try {
                  await context.read<TarefaProvider>().salvarTarefaBase(text, id: isEditing ? tarefaBase.id : null);
                  if (ctx.mounted) Navigator.pop(ctx);
                } catch (e, s) {
                  if (context.mounted) {
                    AppErrorHelper.exibirErro(
                      context,
                      'Erro ao salvar tarefa base',
                      e,
                      stackTrace: s,
                    );
                  }
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, int id, String descricao) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Tarefa?'),
        content: Text('Tem certeza que deseja excluir a tarefa "$descricao"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<TarefaProvider>().excluirTarefaBase(id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tarefa excluída com sucesso!')),
                  );
                }
              } catch (e, s) {
                if (context.mounted) {
                  AppErrorHelper.exibirErro(
                    context,
                    'Erro ao excluir tarefa base',
                    e,
                    stackTrace: s,
                  );
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
