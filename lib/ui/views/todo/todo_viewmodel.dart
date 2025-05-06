import 'package:fala_comigo_app/app/app.bottomsheets.dart';
import 'package:fala_comigo_app/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:fala_comigo_app/models/todoModel.dart';
import 'package:stacked_services/stacked_services.dart';

class TodoViewModel extends BaseViewModel {
  // lista de tarefas baseadas nos itens do modelo de to-dos
  final List<TodoModel> _todos = [];
//variavel pra chamar o bottomsheet
  final _bottomSheetService = locator<BottomSheetService>();

  // getters
  List<TodoModel> get todos => _todos;

  void onAddTodo(TodoModel todo) {
    _todos.add(todo);
    notifyListeners();
  }

  //removendo task
  void onRemoveTodo(TodoModel todo) {
    // remove a task de acordo com o id de onde o user clica
    _todos.removeWhere((t) => t.id == todo.id);

    notifyListeners();
  }

  //conclui a caixinha da task
  void onChangeCompletedTodo(TodoModel todoToUpdate) {
    final index = _todos.indexWhere((t) => t.id == todoToUpdate.id);

    // se a task for encontrada, eh marcada como concluida? meio confuso
    if (index != -1) {
      _todos[index] = todoToUpdate.copyWith(completed: !todoToUpdate.completed);

      notifyListeners();
    }
  }

  // logica para mostrar quantas tarefas estao incompletas(se existirem)
  String get todoStatusString {
    final notCompletedTodos = _todos.where((todo) => !todo.completed);

    if (_todos.isEmpty) {
      return "Você não possui nenhuma tarefa";
    } else if (notCompletedTodos.isEmpty) {
      return "Parabéns! Todas as tarefas estão completas!";
    }
    return "Você possui ${notCompletedTodos.length} tarefa${notCompletedTodos.length == 1 ? '' : 's'}";
  }

  void openBottomSheet() async {
    final response = await _bottomSheetService.showCustomSheet(
      //precisa do await pq tem que esperar o form
      variant: BottomSheetType.formSheet,
    );

    if (response?.confirmed == true && response?.data != null) {
      onAddTodo(response!.data); // adiciona a tarefa
    }
  }
}
