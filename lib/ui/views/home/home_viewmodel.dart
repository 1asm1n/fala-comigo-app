import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:fala_comigo_app/app/app.locator.dart';
import 'package:fala_comigo_app/app/app.router.dart';

class HomeViewModel extends BaseViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _navigationService = locator<NavigationService>();

  User? get currentUser => _auth.currentUser;

  // Adiciona o chatbot como um "usuário" fixo
  Map<String, dynamic> get chatbotUser => {
        'uid': 'deepseek_bot',
        'nome': 'Assistente Virtual',
        'avatarUrl': 'https://example.com/bot_icon.png', // Adicione um ícone
        'isBot': true,
      };

  Stream<List<Map<String, dynamic>>> get otherUsersStream {
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore.collection('users').snapshots().map((snapshot) {
      // Combina usuários reais com o chatbot
      final realUsers =
          snapshot.docs.where((doc) => doc.id != currentUser!.uid).map((doc) {
        return {
          'uid': doc.id,
          'nome': doc['nome'] ?? 'Nome não disponível',
          'avatarUrl': doc['avatarUrl'] ?? '',
          'isBot': false,
        };
      }).toList();

      return [chatbotUser]..addAll(realUsers);
    });
  }

  Future<void> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      final user = userCredential.user;
      if (user != null) {
        final userDoc =
            await _firestore.collection('users').doc(user.uid).get();
        if (!userDoc.exists) {
          await _firestore.collection('users').doc(user.uid).set({
            'nome': user.displayName ?? 'Sem nome',
            'email': user.email,
            'avatarUrl': user.photoURL ?? '',
            'criadoEm': FieldValue.serverTimestamp(),
          });
        }
      }
      notifyListeners();
    } catch (e) {
      print('Erro ao fazer login com Google: $e');
    }
  }

  void logout() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
    _navigationService.navigateTo(Routes.cadastroView);
  }

  // Método para navegar para o chat apropriado
  void navigateToChat(Map<String, dynamic> user) {
    if (user['isBot'] == true) {
      _navigationService.navigateToChatbotView();
    } else {
      _navigationService.navigateToChatView(
        otherUserId: user['uid'],
        nome: user['nome'],
      );
    }
  }
}
