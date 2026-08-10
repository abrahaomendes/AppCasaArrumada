import 'package:flutter/material.dart';
import '../pessoas/pessoas_screen.dart';
import '../tarefas/tarefas_screen.dart';
import '../../core/constants/app_colors.dart';

class ConfiguracoesScreen extends StatelessWidget {
  const ConfiguracoesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes & Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          ListTile(
            leading: const ContainerIcon(
              icon: Icons.people_alt_rounded,
              color: AppColors.primary,
            ),
            title: const Text('Pessoas',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Cadastrar, editar e gerenciar moradores'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const PessoasScreen()),
              );
            },
          ),
          const Divider(indent: 72),
          ListTile(
            leading: const ContainerIcon(
              icon: Icons.repeat_rounded,
              color: AppColors.accent,
            ),
            title: const Text('Tarefas Semanais',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Configurar tarefas recorrentes e responsáveis'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const TarefasScreen()),
              );
            },
          ),
          const Divider(indent: 72),
          ListTile(
            leading: const ContainerIcon(
              icon: Icons.info_outline_rounded,
              color: AppColors.warning,
            ),
            title: const Text('Sobre o Aplicativo',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Casa em Ordem v1.0.0 — 100% Local & Offline'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Casa em Ordem',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.home_work, size: 48, color: AppColors.primary),
                children: const [
                  Text(
                    'Aplicativo simples, rápido e amigável para gerenciamento e gamificação de tarefas domésticas semanais com persistência SQLite local.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class ContainerIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const ContainerIcon({
    super.key,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
