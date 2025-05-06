import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'chatbot_viewmodel.dart';

class ChatbotView extends StatelessWidget {
  const ChatbotView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ChatbotViewModel>.reactive(
      viewModelBuilder: () => ChatbotViewModel(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Taskito'),
            backgroundColor: const Color(0xFFE6A0B7),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => _showResetDialog(context, viewModel),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFCEEF1),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    final messageIndex = viewModel.messages.length - 1 - index;
                    final message = viewModel.messages[messageIndex];
                    return _buildMessageBubble(
                      message,
                      context,
                      viewModel,
                      messageIndex,
                    );
                  },
                ),
              ),
              _buildInputField(viewModel, context),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showResetDialog(
      BuildContext context, ChatbotViewModel viewModel) async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nova conversa'),
          content:
              const Text('Tem certeza que deseja começar uma nova conversa?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      viewModel.startNewConversation();
    }
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> message,
    BuildContext context,
    ChatbotViewModel viewModel,
    int messageIndex,
  ) {
    final isUser = message['sender'] == 'user';
    final hasTasks = message.containsKey('tasks') && message['tasks'] != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.85,
            ),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFFFADADD) : const Color(0xFFF5E1E9),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser
                    ? const Radius.circular(16)
                    : const Radius.circular(4),
                bottomRight: isUser
                    ? const Radius.circular(4)
                    : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message['text'] != null &&
                    message['text'].toString().isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: hasTasks ? 8 : 0),
                    child: Text(
                      message['text'],
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                if (hasTasks)
                  ..._buildTaskList(message['tasks'], viewModel, messageIndex),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _formatTime(message['time']),
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTaskList(
    List<dynamic> tasks,
    ChatbotViewModel viewModel,
    int messageIndex,
  ) {
    return tasks.asMap().entries.map((entry) {
      final taskIndex = entry.key;
      final task = entry.value as Map<String, dynamic>;
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: _buildTaskItem(task, viewModel, messageIndex, taskIndex),
      );
    }).toList();
  }

  Widget _buildTaskItem(
    Map<String, dynamic> task,
    ChatbotViewModel viewModel,
    int messageIndex,
    int taskIndex,
  ) {
    if (task['isEditing'] == true) {
      return _buildTaskEditor(task, viewModel, messageIndex, taskIndex);
    }

    final coins = task['coins'] is int
        ? task['coins']
        : int.tryParse(task['coins'].toString()) ?? 100;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE6A0B7)),
        ),
        child: Column(
          children: [
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Text(
                task['title'] ?? 'Tarefa',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6D6875),
                ),
              ),
              trailing: Chip(
                backgroundColor: _getCoinsColor(coins),
                label: Text(
                  '$coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Divider(height: 1, color: Colors.grey[200]),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  color: Colors.blue,
                  onPressed: () => viewModel.editTask(messageIndex, taskIndex),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  color: Colors.red,
                  onPressed: () =>
                      viewModel.deleteTask(messageIndex, taskIndex),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskEditor(
    Map<String, dynamic> task,
    ChatbotViewModel viewModel,
    int messageIndex,
    int taskIndex,
  ) {
    final titleController = TextEditingController(text: task['tempTitle']);
    final coinsController =
        TextEditingController(text: task['tempCoins']?.toString() ?? '100');

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE6A0B7)),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Tarefa',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: coinsController,
              decoration: const InputDecoration(
                labelText: 'Moedas',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    task['isEditing'] = false;
                    viewModel.notifyListeners();
                  },
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6A0B7),
                  ),
                  onPressed: () {
                    viewModel.updateTask(
                      messageIndex,
                      taskIndex,
                      titleController.text,
                      coinsController.text,
                    );
                  },
                  child: const Text('Salvar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCoinsColor(int coins) {
    if (coins < 50) return const Color(0xFF4CAF50); // Verde
    if (coins < 100) return const Color(0xFF2196F3); // Azul
    if (coins < 150) return const Color(0xFF9C27B0); // Roxo
    return const Color(0xFFE91E63); // Rosa (maior valor)
  }

  Widget _buildInputField(ChatbotViewModel viewModel, BuildContext context) {
    final textController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Digite sua mensagem...',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) {
                        viewModel.sendMessage(text);
                        textController.clear();
                      }
                    },
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Color(0xFFE6A0B7)),
                onPressed: () {
                  if (textController.text.trim().isNotEmpty) {
                    viewModel.sendMessage(textController.text);
                    textController.clear();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String isoTime) {
    try {
      final date = DateTime.parse(isoTime);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
}
