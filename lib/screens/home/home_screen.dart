import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/execucao_tarefa.dart';
import '../../providers/execucao_provider.dart';
import '../../providers/pessoa_provider.dart';
import '../../providers/tarefa_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/error_helper.dart';
import '../../widgets/tarefa_card.dart';
import 'widgets/dia_selector.dart';
import 'widgets/add_extra_dialog.dart';
import '../pessoas/pessoas_screen.dart';
import '../tarefas/tarefas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExecucaoProvider>().inicializarECarregar();
      context.read<PessoaProvider>().carregarPessoas();
    });
  }

  void _abrirModalExtra(BuildContext context) {
    final pessoas = context.read<PessoaProvider>().pessoas;
    if (pessoas.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastre pelo menos uma pessoa antes de adicionar tarefas extras.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AddExtraDialog(
        pessoas: pessoas,
        onSalvar: (pessoaId, descricao) async {
          try {
            await context.read<ExecucaoProvider>().adicionarTarefaExtra(
                  pessoaId: pessoaId,
                  descricao: descricao,
                );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⭐ Tarefa extra adicionada com +2 pontos!'),
                  backgroundColor: AppColors.success,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } catch (e, s) {
            if (context.mounted) {
              AppErrorHelper.exibirErro(
                context,
                'Erro ao adicionar tarefa extra',
                e,
                stackTrace: s,
              );
            }
          }
        },
      ),
    );
  }

  void _confirmarExclusaoExecucao(BuildContext context, ExecucaoTarefa exec, ExecucaoProvider execProvider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir da Semana?'),
        content: Text(
          'Deseja remover "${exec.descricao}" deste dia/semana?\n\n'
          'Esta ação também removerá o vínculo em "Ajustes -> Tarefas e Vínculos". '
          'A tarefa base continuará salva em "Tarefas da Casa".',
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
              try {
                if (exec.id != null) {
                  await execProvider.removerExecucaoTarefa(exec.id!);
                  if (mounted) {
                    context.read<TarefaProvider>().carregarTarefas();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tarefa "${exec.descricao}" removida da semana e dos vínculos.')),
                    );
                  }
                }
              } catch (e, s) {
                if (mounted) {
                  AppErrorHelper.exibirErro(
                    context,
                    'Erro ao apagar tarefa da semana',
                    e,
                    stackTrace: s,
                  );
                }
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
    final execProvider = context.watch<ExecucaoProvider>();
    final data = execProvider.dataSelecionada;
    final nomeDia = AppDateUtils.getDayNamePtBr(data.weekday);
    final dataFormatada = AppDateUtils.formatDisplayDate(data);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nomeDia,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              dataFormatada,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary, size: 28),
            tooltip: 'Semana Anterior',
            onPressed: () {
              execProvider.selecionarData(data.subtract(const Duration(days: 7)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 28),
            tooltip: 'Próxima Semana',
            onPressed: () {
              execProvider.selecionarData(data.add(const Duration(days: 7)));
            },
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: AppColors.textSecondary),
            tooltip: 'Escolher Data',
            onPressed: () async {
              final dataEscolhida = await showDatePicker(
                context: context,
                initialDate: data,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primary,
                        onPrimary: Colors.white,
                        onSurface: AppColors.textPrimary,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (dataEscolhida != null) {
                execProvider.selecionarData(dataEscolhida);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.today_rounded, color: AppColors.primary),
            tooltip: 'Ir para Hoje',
            onPressed: () {
              execProvider.selecionarData(DateTime.now());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Seletor horizontal de dias
          DiaSelector(
            dias: execProvider.diasDaSemanaAtual,
            dataSelecionada: data,
            onSelectDia: (novaData) {
              execProvider.selecionarData(novaData);
            },
          ),
          const Divider(height: 1, color: AppColors.border),

          // Lista de tarefas por pessoa
          Expanded(
            child: execProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : execProvider.grupos.isEmpty
                    ? _buildEmptyState(context)
                    : RefreshIndicator(
                        onRefresh: () => execProvider.inicializarECarregar(),
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          itemCount: execProvider.grupos.length,
                          itemBuilder: (context, index) {
                            final grupo = execProvider.grupos[index];
                            return _buildPessoaSection(context, grupo, execProvider);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirModalExtra(context),
        backgroundColor: AppColors.warning,
        icon: const Icon(Icons.stars_rounded, color: Colors.white),
        label: const Text(
          '+ Tarefa Extra',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildPessoaSection(
    BuildContext context,
    PessoaExecucoesGroup grupo,
    ExecucaoProvider execProvider,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                      child: grupo.pessoa.avatar != null && grupo.pessoa.avatar!.isNotEmpty
                          ? Text(
                              grupo.pessoa.avatar!,
                              style: const TextStyle(fontSize: 16),
                            )
                          : Text(
                              grupo.pessoa.nome.isNotEmpty
                                  ? grupo.pessoa.nome[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryDark,
                              ),
                            ),
                    ),
                    if (context.read<PessoaProvider>().vencedorSemanaAnteriorId == grupo.pessoa.id)
                      const Positioned(
                        top: -6,
                        right: -6,
                        child: Text('👑', style: TextStyle(fontSize: 14)),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Text(
                  grupo.pessoa.nome,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (grupo.execucoes.isEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4, bottom: 8),
              child: Text(
                'Nenhuma tarefa agendada para este dia.',
                style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary.withOpacity(0.8),
                ),
              ),
            )
          else
            ...grupo.execucoes.map((exec) {
              return TarefaCard(
                execucao: exec,
                onConcluir: () async {
                  if (exec.id != null && exec.status == 'PENDENTE') {
                    try {
                      final ok = await execProvider.concluirTarefa(exec.id!);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🙂 +1 Ponto registrado com sucesso!'),
                            backgroundColor: AppColors.success,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    } catch (e, s) {
                      if (mounted) {
                        AppErrorHelper.exibirErro(
                          context,
                          'Erro ao concluir tarefa',
                          e,
                          stackTrace: s,
                        );
                      }
                    }
                  }
                },
                onDesfazer: () async {
                  if (exec.id == null) return;
                  
                  try {
                    if (exec.isExtra) {
                      await execProvider.removerTarefaExtra(exec.id!);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('🗑️ Tarefa extra removida.'),
                            backgroundColor: AppColors.textSecondary,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    } else if (exec.status == 'CONCLUIDA') {
                      final ok = await execProvider.desfazerConclusaoTarefa(exec.id!);
                      if (ok && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('↩️ Conclusão desfeita.'),
                            backgroundColor: AppColors.warning,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      }
                    }
                  } catch (e, s) {
                    if (mounted) {
                      AppErrorHelper.exibirErro(
                        context,
                        'Erro ao desfazer ação',
                        e,
                        stackTrace: s,
                      );
                    }
                  }
                },
                onExcluir: () {
                  if (exec.id != null) {
                    _confirmarExclusaoExecucao(context, exec, execProvider);
                  }
                },
              );
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_work_outlined,
                size: 64, color: AppColors.primaryLight),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma pessoa ou tarefa cadastrada!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre os moradores da casa e as tarefas recorrentes para começar a pontuação.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_add),
                  label: const Text('Pessoas'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PessoasScreen()),
                    );
                  },
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.add_task),
                  label: const Text('Tarefas'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const TarefasScreen()),
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
