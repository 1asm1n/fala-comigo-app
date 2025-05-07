import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'form_sheet_model.dart';

class FormSheet extends StackedView<FormSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;

  const FormSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  FormSheetModel viewModelBuilder(BuildContext context) =>
      FormSheetModel(completer);

  @override
  Widget builder(
    BuildContext context,
    FormSheetModel viewModel,
    Widget? child,
  ) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: viewModel.formKey, // validação com formKey da ViewModel
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // obrigatoriedade do título
              TextFormField(
                controller: viewModel.titleTEC,
                style: const TextStyle(color: Colors.white),
                validator: (String? newTitle) {
                  if (newTitle == null || newTitle.isEmpty) {
                    return "Por favor insira um título";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Título',
                ),
              ),
              const SizedBox(height: 8),
              // campo opcional de descrição
              TextFormField(
                controller: viewModel.descriptionTEC,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Descrição',
                ),
              ),
              const SizedBox(height: 16),
              // botão de adicionar tarefa
              ElevatedButton(
                onPressed: viewModel.onAddTodo,
                child: const Text('Adicionar tarefa'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
