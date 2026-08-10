import 'package:flutter/material.dart';
import '../../models/pessoa.dart';
import '../../core/constants/app_colors.dart';

class PessoaFormDialog extends StatefulWidget {
  final Pessoa? pessoaParaEditar;

  const PessoaFormDialog({super.key, this.pessoaParaEditar});

  @override
  State<PessoaFormDialog> createState() => _PessoaFormDialogState();
}

class _PessoaFormDialogState extends State<PessoaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomeController;
  String? _avatarSelecionado;

  final List<String> _opcoesAvatares = [
    '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮',
    '🐷', '🐸', '🐵', '🦄', '🦖', '🐙', '🚀', '🌟', '🎸', '🎮', '⚽', '🎨'
  ];

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(
      text: widget.pessoaParaEditar?.nome ?? '',
    );
    _avatarSelecionado = widget.pessoaParaEditar?.avatar;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.pessoaParaEditar != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEditing ? 'Editar Pessoa' : 'Nova Pessoa'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeController,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex: Abraão, Ana, João',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'Informe o nome da pessoa';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Escolha um Avatar (Opcional):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _opcoesAvatares.map((emoji) {
                  final isSelected = _avatarSelecionado == emoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _avatarSelecionado = isSelected ? null : emoji;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryLight.withOpacity(0.5)
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  );
                }).toList(),
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
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'nome': _nomeController.text.trim(),
                'avatar': _avatarSelecionado,
              });
            }
          },
          child: Text(isEditing ? 'Salvar' : 'Adicionar'),
        ),
      ],
    );
  }
}
