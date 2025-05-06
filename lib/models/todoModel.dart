import 'package:uuid/uuid.dart';

// modelo de dados para representar um item de tarefa
class TodoModel {
  final String id;
  final String title;
  final String? description; // ? porque é opcional, pode ser nula
  final bool completed; // indica se a tarefa foi completada ou nao

  TodoModel(this.title, {String? descriptionC, String? idC, bool? completedC})
      : id = idC ??
            const Uuid()
                .v4(), //se o idC for nulo vamos inicializa-lo com o package Uuid que cria identificadores
        completed =
            completedC ?? false, //se o completed for nulo ele ja começa falso
        description = descriptionC; //description pode ser nulo então, certo?

  TodoModel copyWith({
    //esses parametros sao opcionais?
    String? id,
    String? title,
    String? description,
    bool? completed,
  }) {
    return TodoModel(
      title ?? this.title,
      descriptionC: description ?? this.description,
      idC: id ?? this.id,
      completedC: completed ?? this.completed,
    );
  }
}
