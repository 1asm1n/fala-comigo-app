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

  void initialize(String otherUid) {
    otherUserId = otherUid;
    chatId = _generateChatId(currentUserId, otherUserId);
    _updateUserStatus();
    _markMessagesAsRead();
    notifyListeners();
  }

  String _generateChatId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

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
        'isRead': false,
      });

      message = '';
      messageController.clear();
      notifyListeners();
    } catch (e) {
      print('Erro ao enviar mensagem: \$e');
    }
  }

  Stream<QuerySnapshot> getMessagesStream() {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void updateMessage(String val) {
    message = val;
  }

  Future<void> _markMessagesAsRead() async {
    final query = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isEqualTo: otherUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in query.docs) {
      await doc.reference.update({'isRead': true});
    }
  }

  Stream<DocumentSnapshot> getOtherUserStream() {
    return _firestore.collection('users').doc(otherUserId).snapshots();
  }

  String getLastSeenStatus(Timestamp? lastSeen) {
    if (lastSeen == null) return 'Online agora';
    final difference = DateTime.now().difference(lastSeen.toDate());
    if (difference.inMinutes < 2) return 'Online agora';
    if (difference.inMinutes < 60)
      return 'Online há ${difference.inMinutes} minutos';
    if (difference.inHours < 24) return 'Online há ${difference.inHours} horas';
    return 'Online há mais de um dia';
  }

  Future<void> _updateUserStatus() async {
    await _firestore.collection('users').doc(currentUserId).update({
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }
}
