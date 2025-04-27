import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fala_comigo_app/app/app.locator.dart';
import 'package:fala_comigo_app/app/app.router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CadastroViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  TextEditingController nomeController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController idadeController = TextEditingController();

  int idade = 0;
  bool menorDeIdade = false;

  void setIdade(String value) {
    final intValue = int.tryParse(value) ?? 0;
    idade = intValue;
    menorDeIdade = idade < 12;
    notifyListeners();
  }

  Future<void> cadastrar() async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await _salvarDadosUsuario(credential.user!);
      _navigationService.replaceWithHomeView();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('Senha muito fraca.');
      } else if (e.code == 'email-already-in-use') {
        print('Email já está em uso.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> loginComGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // usuário cancelou

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      await _salvarDadosUsuario(userCredential.user!);
      _navigationService.replaceWithHomeView();
    } catch (e) {
      print("Erro no login com Google: $e");
    }
  }

  Future<void> _salvarDadosUsuario(User user) async {
    final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await doc.get();

    if (!snapshot.exists) {
      await doc.set({
        'nome': user.displayName ?? nomeController.text.trim(),
        'email': user.email,
        'idade': idade,
        'menorDeIdade': menorDeIdade,
        'avatarUrl': user.photoURL ??
            'https://api.dicebear.com/7.x/initials/svg?seed=${user.displayName?.replaceAll(' ', '+') ?? 'User'}',
      });
    }
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    passwordController.dispose();
    idadeController.dispose();
    super.dispose();
  }
}
