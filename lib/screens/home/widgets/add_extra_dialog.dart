import 'package:flutter/material.dart';
import '../../../models/pessoa.dart';
import '../../../core/constants/app_colors.dart';

class AddExtraDialog extends StatefulWidget {
  final List<Pessoa> pessoas;
  final Function(int pessoaId, String descricao) onSalvar;

  const AddExtraDialog({
    super.key,
    required this.pessoas,
    required this.onSalvar,
  });

  @override
  State<AddExtraDialog> createState() => _AddExtraDialogState();
}

class _AddExtraDialogState extends State<AddExtraDialog> {
  int? _pessoaIdSelecionada;
  final TextEditingController _descricaoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.pessoas.isNotEmpty) {
      _pessoaIdSelecionada = widget.pessoas.first.id;
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(Icons.stars_rounded, color: AppColors.warning, size: 28),
          SizedBox(width: 8),
          Text('Adicionar Tarefa Extra'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Text('⭐ ', style: TextStyle(fontSize: 16)),
                    Expanded(
                      child: Text(
                        'Gera +2 pontos automáticos e já fica marcada como concluída!',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.bronze,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Responsável:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _pessoaIdSelecionada,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: widget.pessoas.map((p) {
                  final avatarStr = (p.avatar != null && p.avatar!.isNotEmpty) ? '${p.avatar} ' : '';
                  return DropdownMenuItem<int>(
                    value: p.id,
                    child: Text('$avatarStr${p.nome}'),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _pessoaIdSelecionada = val;
                  });
                },
                validator: (val) =>
                    val == null ? 'Selecione uma pessoa' : null,
              ),
              const SizedBox(height: 16),
              const Text('Descrição:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descricaoController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Ex: Organizar a garagem',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'Informe a descrição da tarefa';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar',
              style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warning,
          ),
          icon: const Icon(Icons.add_task, color: Colors.white),
          label: const Text('+2 Adicionar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          onPressed: () {
            if (_formKey.currentState!.validate() &&
                _pessoaIdSelecionada != null) {
              widget.onSalvar(
                _pessoaIdSelecionada!,
                _descricaoController.text.trim(),
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}
