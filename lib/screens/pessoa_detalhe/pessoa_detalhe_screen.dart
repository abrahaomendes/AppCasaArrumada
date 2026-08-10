import 'package:flutter/material.dart';
import '../../database/dao/pontuacao_dao.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/week_calculator.dart';

class PessoaDetalheScreen extends StatefulWidget {
  final int pessoaId;
  final String nomePessoa;

  const PessoaDetalheScreen({
    super.key,
    required this.pessoaId,
    required this.nomePessoa,
  });

  @override
  State<PessoaDetalheScreen> createState() => _PessoaDetalheScreenState();
}

class _PessoaDetalheScreenState extends State<PessoaDetalheScreen> {
  final PontuacaoDao _pontuacaoDao = PontuacaoDao();
  PontuacaoResumoPessoa? _resumo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final semanaAtual = WeekCalculator.getAppWeek(DateTime.now());
    final resumo = await _pontuacaoDao.getResumoPessoaNaSemana(
      widget.pessoaId,
      semanaAtual.week,
      semanaAtual.year,
    );

    setState(() {
      _resumo = resumo;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalTarefas = (_resumo?.tarefasFelizes ?? 0) +
        (_resumo?.tarefasInfelizes ?? 0) +
        (_resumo?.tarefasExtras ?? 0);
    final concluidasSucesso = (_resumo?.tarefasFelizes ?? 0) + (_resumo?.tarefasExtras ?? 0);
    final taxaConclusao = totalTarefas > 0
        ? ((concluidasSucesso / totalTarefas) * 100).toStringAsFixed(0)
        : '100';

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.nomePessoa),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Card Header com Avatar e Pontuação
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: _resumo?.avatar != null && _resumo!.avatar!.isNotEmpty
                              ? Text(
                                  _resumo!.avatar!,
                                  style: const TextStyle(fontSize: 40),
                                )
                              : Text(
                                  widget.nomePessoa.isNotEmpty
                                      ? widget.nomePessoa[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.nomePessoa,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '⭐ ${_resumo?.totalPontos ?? 0} Pontos nesta semana',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Estatísticas detalhadas
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Desempenho Semanal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '🙂 Positivas',
                          '${_resumo?.tarefasFelizes ?? 0}',
                          AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          '☹️ Negativas',
                          '${_resumo?.tarefasInfelizes ?? 0}',
                          AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          '⭐ Extras',
                          '${_resumo?.tarefasExtras ?? 0}',
                          AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          '📈 Taxa Conclusão',
                          '$taxaConclusao%',
                          AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String titulo, String valor, Color cor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}
