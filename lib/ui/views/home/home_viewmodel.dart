import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fala_comigo_app/app/app.locator.dart';
import 'package:fala_comigo_app/app/app.router.dart';
import 'package:fala_comigo_app/models/chatUserModel';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  List<ChatUserModel> _chats = [];
  List<ChatUserModel> get chats => _chats;

  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final _navigationService = locator<NavigationService>();
  HomeViewModel() {
    fetchUsers();
  }

  void logout() {
    _navigationService.replaceWithCadastroView();
  }

  Future<void> fetchUsers() async {
    setBusy(true);
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();

      _chats = snapshot.docs
          .where((doc) => doc.id != _currentUserId)
          .map((doc) => ChatUserModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Erro ao buscar usuários: $e');
    }
    setBusy(false);
  }
}
