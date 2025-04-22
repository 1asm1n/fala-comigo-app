import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class ChatViewModel extends BaseViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String otherUserId = '';
  String chatId = '';
  String message = '';
  TextEditingController messageController = TextEditingController();

  // Inicialização com o ID do outro usuário
  void initialize(String otherUid) {
    otherUserId = otherUid;
    chatId = _generateChatId(currentUserId, otherUserId);
    notifyListeners();
  }

  // Gerar ID de chat único baseado nos dois usuários
  String _generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  // Enviar mensagem para o Firestore
  Future<void> sendMessage() async {
    if (message.trim().isEmpty) return;

    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      message = '';
      messageController.clear();
      notifyListeners();
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
    }
  }

  // Stream de mensagens, ordenadas pelo timestamp
  Stream<QuerySnapshot> getMessagesStream() {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Atualizar mensagem digitada
  void updateMessage(String val) {
    message = val;
  }
}
