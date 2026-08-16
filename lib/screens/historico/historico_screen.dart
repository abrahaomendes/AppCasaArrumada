import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ranking_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/week_calculator.dart';
import '../pessoa_detalhe/pessoa_detalhe_screen.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RankingProvider>().carregarRanking();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rProvider = context.watch<RankingProvider>();
    final semanaStr = rProvider.semanaSelecionada.toString();
    final ranking = rProvider.ranking;
    
    final semanaAtual = WeekCalculator.getAppWeek(DateTime.now());
    final isSemanaPassada = rProvider.semanaSelecionada.year < semanaAtual.year || 
        (rProvider.semanaSelecionada.year == semanaAtual.year && rProvider.semanaSelecionada.week < semanaAtual.week);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico Semanal'),
      ),
      body: Column(
        children: [
          // Navegador de Semanas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 30),
                  onPressed: () => rProvider.semanaAnterior(),
                ),
                Text(
                  semanaStr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 30),
                  onPressed: () => rProvider.semanaSeguinte(),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          Expanded(
            child: rProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ranking.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.history_toggle_off,
                                size: 56, color: AppColors.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              'Sem registros para $semanaStr',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Banner do Vencedor da Semana
                          if (ranking.isNotEmpty && ranking.first.totalPontos > 0)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: AppColors.gold, width: 1.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text('🏆',
                                          style: TextStyle(fontSize: 36)),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Vencedor da Semana',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.bronze,
                                              ),
                                            ),
                                            Text(
                                              ranking.first.nomePessoa,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${ranking.first.totalPontos} pts',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isSemanaPassada && ranking.first.pedidoSemana != null) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.star_rounded, color: AppColors.gold, size: 20),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Pedido: ${ranking.first.pedidoSemana}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                          // Lista de Desempenhos no Histórico
                          ...ranking.map((item) {
                            return Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      AppColors.primaryLight.withOpacity(0.3),
                                  child: Text(
                                    item.nomePessoa[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.nomePessoa,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(
                                  '🙂 ${item.tarefasFelizes}  •  ☹️ ${item.tarefasInfelizes}  •  ⭐ ${item.tarefasExtras} extras',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                trailing: Text(
                                  '${item.totalPontos} pts',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => PessoaDetalheScreen(
                                        pessoaId: item.pessoaId,
                                        nomePessoa: item.nomePessoa,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
