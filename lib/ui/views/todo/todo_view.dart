import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'todo_viewmodel.dart';

class TodoView extends StackedView<TodoViewModel> {
  const TodoView({super.key});

  @override
  Widget builder(
    BuildContext context,
    TodoViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          ' Lista de tarefas ',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          // Botão de adicionar tarefa
          //TODO: no onPressed chamar bottomsheet
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () => viewModel
                .openBottomSheet(), // chama o metodo na viewmodel p abrir o bottomsheet do form
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // design dos status da tarefa (parabéns, tarefas completas! e você tem x tarefas)
            Center(
              child: Text(
                viewModel.todoStatusString, // mostra o status das tarefas
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            // lista de tarefas
            Expanded(
              child: ListView.builder(
                itemCount: viewModel.todos.length, // conhta as tarefas
                itemBuilder: (_, int index) {
                  final todo = viewModel.todos[index]; //criando a lista

                  return ListTile(
                    leading: Checkbox(
                      value: todo.completed,
                      onChanged: (_) => viewModel.onChangeCompletedTodo(
                          todo), // checa a tarefa como completa
                    ),
                    title: Text(
                      todo.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      todo.description ?? '', // mostra descricao se tiver
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () => viewModel
                          .onRemoveTodo(todo), //remove a tarefa no menos
                      icon: const Icon(Icons.remove_circle, color: Colors.red),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  TodoViewModel viewModelBuilder(BuildContext context) => TodoViewModel();
}
