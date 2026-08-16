import 'package:flutter/material.dart';
import '../models/execucao_tarefa.dart';
import '../core/constants/app_colors.dart';

class TarefaCard extends StatelessWidget {
  final ExecucaoTarefa execucao;
  final VoidCallback? onConcluir;
  final VoidCallback? onDesfazer;
  final VoidCallback? onExcluir;

  const TarefaCard({
    super.key,
    required this.execucao,
    this.onConcluir,
    this.onDesfazer,
    this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    if (execucao.isExtra) {
      return _buildCardExtra(context);
    }

    switch (execucao.status) {
      case ExecucaoStatus.concluida:
        return _buildCardConcluido(context);
      case ExecucaoStatus.naoConcluida:
        return _buildCardNaoConcluido(context);
      case ExecucaoStatus.pendente:
      default:
        return _buildCardPendente(context);
    }
  }

  Widget _buildCardPendente(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: IconButton(
            icon: const Icon(Icons.check_box_outline_blank_rounded,
                size: 28, color: AppColors.textSecondary),
            onPressed: onConcluir,
          ),
          title: Text(
            execucao.descricao,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Pendente',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (onExcluir != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                  tooltip: 'Apagar da semana',
                  onPressed: onExcluir,
                ),
            ],
          ),
          onTap: onConcluir,
        ),
      ),
    );
  }

  Widget _buildCardConcluido(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.successLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withOpacity(0.5), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onDesfazer,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: IconButton(
            icon: const Icon(
              Icons.check_circle_rounded,
              size: 28,
              color: AppColors.success,
            ),
            onPressed: onDesfazer,
          ),
          title: Text(
            execucao.descricao,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🙂 ', style: TextStyle(fontSize: 14)),
                    Text(
                      '+1',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (onExcluir != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                  tooltip: 'Apagar da semana',
                  onPressed: onExcluir,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardNaoConcluido(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.dangerLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.danger.withOpacity(0.4), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: const Icon(
            Icons.cancel_rounded,
            size: 28,
            color: AppColors.danger,
          ),
          title: Text(
            execucao.descricao,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('☹️ ', style: TextStyle(fontSize: 14)),
                    Text(
                      '-1',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (onExcluir != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                  tooltip: 'Apagar da semana',
                  onPressed: onExcluir,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardExtra(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withOpacity(0.8), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: const Icon(
            Icons.stars_rounded,
            size: 28,
            color: AppColors.warning,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  execucao.descricao,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'EXTRA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.bronze,
                  ),
                ),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🙂 ', style: TextStyle(fontSize: 14)),
                    const Text(
                      '+2',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (onDesfazer != null) ...[
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: onDesfazer,
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                      ),
                    ]
                  ],
                ),
              ),
              if (onExcluir != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.danger),
                  tooltip: 'Apagar da semana',
                  onPressed: onExcluir,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
