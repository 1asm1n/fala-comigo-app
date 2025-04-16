import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:fala_comigo_app/ui/views/chat/chat_viewmodel.dart';

class ChatView extends StackedView<ChatViewModel> {
  final String otherUserId;

  const ChatView({Key? key, required this.otherUserId}) : super(key: key);

  @override
  void onViewModelReady(ChatViewModel viewModel) {
    viewModel.initialize(otherUserId);
  }

  @override
  Widget builder(
    BuildContext context,
    ChatViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
      ),
      body: Column(
        children: [
          // StreamBuilder para mostrar as mensagens
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: viewModel.getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro ao carregar mensagens.'));
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true, // Para a última mensagem aparecer no final
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final senderId = messageData['senderId'] ?? '';
                    final text = messageData['text'] ?? '';
                    final timestamp = messageData['timestamp'] ?? '';

                    return ListTile(
                      title: Text(senderId),
                      subtitle: Text(text),
                      trailing: Text(timestamp.toDate().toString()),
                    );
                  },
                );
              },
            ),
          ),

          // Campo de texto e botão de envio
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: viewModel.messageController,
                    onChanged: (val) {
                      viewModel.updateMessage(val);
                    },
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    viewModel.sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  ChatViewModel viewModelBuilder(BuildContext context) => ChatViewModel();
}
