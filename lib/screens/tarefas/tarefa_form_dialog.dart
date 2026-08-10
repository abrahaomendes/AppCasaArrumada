import 'package:flutter/material.dart';
import '../../models/tarefa.dart';
import '../../models/pessoa.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart';

class TarefaFormDialog extends StatefulWidget {
  final Tarefa? tarefaParaEditar;
  final List<Pessoa> pessoas;

  const TarefaFormDialog({
    super.key,
    this.tarefaParaEditar,
    required this.pessoas,
  });

  @override
  State<TarefaFormDialog> createState() => _TarefaFormDialogState();
}

class _TarefaFormDialogState extends State<TarefaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descricaoController;
  int _diaSemanaSelecionado = 1; // 1 = Segunda
  int? _pessoaIdSelecionada;

  @override
  void initState() {
    super.initState();
    _descricaoController = TextEditingController(
      text: widget.tarefaParaEditar?.descricao ?? '',
    );
    _diaSemanaSelecionado = widget.tarefaParaEditar?.diaSemana ?? DateTime.now().weekday;
    if (widget.pessoas.isNotEmpty) {
      if (widget.tarefaParaEditar != null) {
        _pessoaIdSelecionada = widget.tarefaParaEditar!.pessoaId;
      } else {
        _pessoaIdSelecionada = widget.pessoas.first.id;
      }
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tarefaParaEditar != null;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEditing ? 'Editar Tarefa' : 'Nova Tarefa Recorrente'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Descrição:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descricaoController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Ex: Tirar o lixo, Lavar a louça',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (text) {
                  if (text == null || text.trim().isEmpty) {
                    return 'Informe a descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Dia da Semana:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _diaSemanaSelecionado,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: List.generate(7, (i) {
                  final weekday = i + 1;
                  return DropdownMenuItem<int>(
                    value: weekday,
                    child: Text(AppDateUtils.getDayNamePtBr(weekday)),
                  );
                }),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _diaSemanaSelecionado = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Responsável:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              DropdownButtonFormField<int>(
                value: _pessoaIdSelecionada,
                decoration: InputDecoration(
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
                validator: (val) => val == null ? 'Selecione o responsável' : null,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                    SizedBox(width: 6),
                    Text(
                      'Pontuação padrão: +1 ponto ao concluir',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate() && _pessoaIdSelecionada != null) {
              Navigator.pop(context, {
                'descricao': _descricaoController.text.trim(),
                'diaSemana': _diaSemanaSelecionado,
                'pessoaId': _pessoaIdSelecionada,
              });
            }
          },
          child: Text(isEditing ? 'Salvar' : 'Criar Tarefa'),
        ),
      ],
    );
  }
}
