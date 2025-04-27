import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:fala_comigo_app/ui/views/chat/chat_viewmodel.dart';

class ChatView extends StackedView<ChatViewModel> {
  final String otherUserId;
  final String nome;

  const ChatView({Key? key, required this.otherUserId, required this.nome})
      : super(key: key);

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
      backgroundColor: const Color(0xFFFCEEF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6A0B7),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(nome),
            StreamBuilder<DocumentSnapshot>(
              stream: viewModel.getOtherUserStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data?.data() == null)
                  return const SizedBox.shrink();
                final data = snapshot.data!.data() as Map<String, dynamic>;
                final lastSeen = data['lastSeen'] as Timestamp?;
                final status = viewModel.getLastSeenStatus(lastSeen);
                return Text(
                  status,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: viewModel.getMessagesStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text('Erro ao carregar mensagens.'));
                }

                final messages = snapshot.data?.docs ?? [];

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData =
                        messages[index].data() as Map<String, dynamic>;
                    final senderId = messageData['senderId'] ?? '';
                    final text = messageData['text'] ?? '';
                    final timestamp = messageData['timestamp'] as Timestamp?;
                    final isRead = messageData['isRead'] == true;
                    final isMe = senderId == viewModel.currentUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 12),
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFFFADADD)
                              : const Color(0xFFF5E1E9),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: isMe
                                ? const Radius.circular(16)
                                : const Radius.circular(0),
                            bottomRight: isMe
                                ? const Radius.circular(0)
                                : const Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              text,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.black87),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _formatTimestamp(timestamp),
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(width: 4),
                                  if (isMe)
                                    Icon(
                                      isRead ? Icons.done_all : Icons.done_all,
                                      size: 16,
                                      color: isRead ? Colors.red : Colors.grey,
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: viewModel.messageController,
                    onChanged: (val) => viewModel.updateMessage(val),
                    decoration: InputDecoration(
                      hintText: 'Digite uma mensagem...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
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
                  onPressed: () => viewModel.sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  ChatViewModel viewModelBuilder(BuildContext context) =>
      ChatViewModel()..initialize(otherUserId);

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }
}
