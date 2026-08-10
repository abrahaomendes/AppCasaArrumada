import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/ranking_provider.dart';
import '../../database/dao/pontuacao_dao.dart';
import '../../core/constants/app_colors.dart';
import '../pessoa_detalhe/pessoa_detalhe_screen.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🏆 Ranking da Semana'),
            Text(
              rProvider.semanaSelecionada.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: rProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : rProvider.ranking.isEmpty
              ? _buildEmptyRanking()
              : RefreshIndicator(
                  onRefresh: () => rProvider.carregarRanking(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: rProvider.ranking.length,
                    itemBuilder: (context, index) {
                      final item = rProvider.ranking[index];
                      final posicao = index + 1;

                      return _buildRankingCard(context, item, posicao);
                    },
                  ),
                ),
    );
  }

  Widget _buildRankingCard(
      BuildContext context, PontuacaoResumoPessoa item, int posicao) {
    Color corPosicao;
    Widget badgePosicao;

    switch (posicao) {
      case 1:
        corPosicao = AppColors.gold;
        badgePosicao = const Text('🥇 1º',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
        break;
      case 2:
        corPosicao = AppColors.silver;
        badgePosicao = const Text('🥈 2º',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
        break;
      case 3:
        corPosicao = AppColors.bronze;
        badgePosicao = const Text('🥉 3º',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
        break;
      default:
        corPosicao = AppColors.textSecondary;
        badgePosicao = Text('$posicaoº',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: posicao == 1 ? AppColors.gold : AppColors.border,
          width: posicao == 1 ? 2 : 1,
        ),
        boxShadow: posicao == 1
            ? [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: corPosicao.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: badgePosicao,
        ),
        title: Row(
          children: [
            if (item.avatar != null && item.avatar!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(item.avatar!, style: const TextStyle(fontSize: 20)),
              ),
            Expanded(
              child: Text(
                item.nomePessoa,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Text('🙂 ${item.tarefasFelizes}',
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 10),
              Text('☹️ ${item.tarefasInfelizes}',
                  style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 10),
              Text('⭐ +${item.tarefasExtras} extras',
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.bronze)),
            ],
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.totalPontos}',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: posicao == 1 ? AppColors.gold : AppColors.primary,
              ),
            ),
            const Text(
              'pontos',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
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
      ),
    );
  }

  Widget _buildEmptyRanking() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events_outlined,
              size: 64, color: AppColors.textSecondary),
          SizedBox(height: 16),
          Text(
            'Nenhuma pontuação nesta semana',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Conclua tarefas na tela inicial para pontuar no ranking!',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
