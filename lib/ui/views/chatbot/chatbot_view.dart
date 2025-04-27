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
            title: const Text('Dialogpt'),
            backgroundColor: const Color(0xFFE6A0B7),
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

  Widget _buildMessageBubble(
      Map<String, String> message, BuildContext context) {
    final isUser = message['sender'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFFFADADD) : const Color(0xFFF5E1E9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft:
                isUser ? const Radius.circular(16) : const Radius.circular(0),
            bottomRight:
                isUser ? const Radius.circular(0) : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message['text']!,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message['time']!),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(ChatbotViewModel viewModel) {
    final textController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: InputDecoration(
                hintText: 'Digite uma mensagem...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
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
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
