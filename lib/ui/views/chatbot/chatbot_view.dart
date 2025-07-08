import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:taskplay/ui/views/chatbot/chatbot_viewmodel.dart';
import 'package:taskplay/ui/views/components/task_widget.dart';

class ChatbotView extends StatelessWidget {
  final ChatbotViewModel viewModel = ChatbotViewModel();

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatbotViewModel>.reactive( //mudar p versao mais recente
      viewModelBuilder: () => viewModel,
      onViewModelReady: (viewModel) {
        viewModel.startNewConversation();
      },
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Taskito'),

          ),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  //TODO: separar as msgs uma da outra
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    final message = viewModel.messages[index];
                    final isBot = message['sender'] == 'bot';
                    final tasks = isBot ? message['tasks'] as List? : null;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            message['text'],
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: isBot ? Colors.white : Colors.green, //teste
                            ),
                          ),
                        ),
                        if (tasks != null)
                          ...tasks.map(
                            (task) => TaskWidget(
                              task: task,
                              onEdit: (task) {
                                viewModel.updateTask(index, tasks.indexOf(task));
                              },
                              onDelete: (task) {
                                viewModel.deleteTask( //nao funciona????????
                                    index, tasks.indexOf(task));
                              },
                            ),
                          ),
                      ],
                    );
                  },
                ),
                //TODO: botao de adicionar task
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: viewModel.textController,
                  decoration: InputDecoration(
                    hintText: 'Digite uma mensagem...',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () {
                        final userMessage = viewModel.textController.text;
                        if (userMessage.trim().isNotEmpty) {
                          viewModel.sendMessage(userMessage);
                          viewModel.textController.clear(); //nao funciona???????????
                        }
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
