import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fala_comigo_app/app/app.locator.dart';
import 'package:fala_comigo_app/app/app.router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _navigationService = locator<NavigationService>();

  // o usuario esta autenticado?
  User? get currentUser => _auth.currentUser;

  // busca outros usuarios
  Stream<List<Map<String, dynamic>>> get otherUsersStream {
    // Garantir que o currentUser não seja null antes de prosseguir
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs
          .where((doc) => doc.id != currentUser!.uid) // Exclui o usuário logado
          .map((doc) {
        // garantindo que todo mundo tem nome e avatar(dados essenciais)
        final nome = doc['nome'] ?? 'Nome não disponível';
        final avatarUrl = doc['avatarUrl'] ?? '';

        return {
          'uid': doc.id,
          'nome': nome,
          'avatarUrl': avatarUrl,
        };
      }).toList();
    });
  }

  void logout() async {
    await _auth.signOut(); // Faz o logout do Firebase
    _navigationService
        .navigateTo(Routes.cadastroView); // Navega para a tela de cadastro
  }
}
