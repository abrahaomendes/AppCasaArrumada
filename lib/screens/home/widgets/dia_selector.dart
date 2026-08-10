import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_utils.dart';

class DiaSelector extends StatelessWidget {
  final List<DateTime> dias;
  final DateTime dataSelecionada;
  final ValueChanged<DateTime> onSelectDia;

  const DiaSelector({
    super.key,
    required this.dias,
    required this.dataSelecionada,
    required this.onSelectDia,
  });

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();

    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: dias.length,
        itemBuilder: (context, index) {
          final dia = dias[index];
          final isSelecionado = _isSameDay(dia, dataSelecionada);
          final isHoje = _isSameDay(dia, hoje);
          final nomeDiaShort = AppDateUtils.getShortDayNamePtBr(dia.weekday);
          final numeroDia = dia.day.toString();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () => onSelectDia(dia),
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                decoration: BoxDecoration(
                  color: isSelecionado ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: isHoje && !isSelecionado
                      ? Border.all(color: AppColors.primary, width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      nomeDiaShort,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelecionado
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      numeroDia,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelecionado
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (isHoje && isSelecionado)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
