import 'package:fala_comigo_app/models/todoModel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class FormSheetModel extends BaseViewModel {
  // lista de tarefas
  final List<TodoModel> _todos = [];

  // getter pra lista
  List<TodoModel> get todos => _todos;

  // controllers p pegar os dados dos campos de texto
  final titleTEC = TextEditingController();
  final descriptionTEC = TextEditingController();

  // chave do formulário para validação (todo form precisa de uma key)
  final formKey = GlobalKey<FormState>();

  // função completer que será chamada quando uma tarefa for adicionada
  Function(SheetResponse)? completer;

  // inicializa o FormSheetModel com o completer vindo da view
  FormSheetModel(this.completer);

  // add tarefa nova
  void onAddTodo(BuildContext context) {
    // verifica se o form eh valido
    if (!formKey.currentState!.validate()) return;

    // cria um ITEM tarefa
    final newTodo = TodoModel(
      titleTEC.text,
      descriptionC: descriptionTEC.text,
    );

    // chama o completer p passar a tarefa p a view principal
    completer?.call(SheetResponse(confirmed: true, data: newTodo));

    // limpa os campos do form
    clearFormFields();

    // notifica os listeners p atualizar a view
    notifyListeners();
  }

  //limpa os campos do formulário
  void clearFormFields() {
    titleTEC.clear();
    descriptionTEC.clear();
  }
}
