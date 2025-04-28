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
                onPressed: () {
                  _showResetDialog(context, viewModel);
                },
              ),
            ],
          ),
          backgroundColor: const Color(0xFFFCEEF1),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    final message = viewModel
                        .messages[viewModel.messages.length - 1 - index];
                    return _buildMessageBubble(message, context);
                  },
                ),
              ),
              _buildInputField(viewModel),
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
      builder: (context) => AlertDialog(
        title: const Text('Nova conversa'),
        content:
            const Text('Tem certeza que deseja começar uma nova conversa?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (shouldReset == true) {
      viewModel.startNewConversation();
    }
  }

  Widget _buildMessageBubble(
      Map<String, String> message, BuildContext context) {
    final isUser = message['sender'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFFADADD) : const Color(0xFFF5E1E9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft:
                isUser ? const Radius.circular(12) : const Radius.circular(4),
            bottomRight:
                isUser ? const Radius.circular(4) : const Radius.circular(12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text']!,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message['time']!),
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(ChatbotViewModel viewModel) {
    final textController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Digite sua mensagem...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  viewModel.sendMessage(text);
                  textController.clear();
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: const Color(0xFFE6A0B7),
            onPressed: () {
              if (textController.text.trim().isNotEmpty) {
                viewModel.sendMessage(textController.text);
                textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  String _formatTime(String isoTime) {
    final date = DateTime.parse(isoTime);
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
