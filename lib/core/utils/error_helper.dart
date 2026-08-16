import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppErrorHelper {
  /// Exibe um SnackBar de erro e permite abrir os detalhes completos em um AlertDialog caso o usuário queira investigar.
  static void exibirErro(
    BuildContext context,
    String titulo,
    dynamic erro, {
    StackTrace? stackTrace,
  }) {
    if (!context.mounted) return;

    final mensagemErro = erro.toString();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.danger,
        duration: const Duration(seconds: 6),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚠️ $titulo',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              mensagemErro,
              style: const TextStyle(fontSize: 12, color: Colors.white),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        action: SnackBarAction(
          label: 'DETALHES',
          textColor: Colors.amberAccent,
          onPressed: () {
            exibirDialogoDetalhes(context, titulo, mensagemErro, stackTrace);
          },
        ),
      ),
    );
  }

  /// Exibe diálogo modal com todos os detalhes e o stack trace do erro.
  static void exibirDialogoDetalhes(
    BuildContext context,
    String titulo,
    String erroDetalhado,
    StackTrace? stackTrace,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.bug_report, color: AppColors.danger),
            const SizedBox(width: 8),
            Expanded(child: Text(titulo, style: const TextStyle(fontSize: 16))),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mensagem de Erro:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 4),
              SelectableText(
                erroDetalhado,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.redAccent),
              ),
              if (stackTrace != null) ...[
                const SizedBox(height: 12),
                const Text(
                  'Stack Trace:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    stackTrace.toString(),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 10),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}
