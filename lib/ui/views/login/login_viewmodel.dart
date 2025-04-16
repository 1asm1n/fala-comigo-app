import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:fala_comigo_app/app/app.locator.dart';
import 'package:fala_comigo_app/app/app.router.dart';

class LoginViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      _navigationService.replaceWithHomeView();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('Nenhum usuário encontrado com esse e-mail.');
      } else if (e.code == 'wrong-password') {
        print('Senha incorreta.');
      } else {
        print('Erro de autenticação: ${e.code}');
      }
    } catch (e) {
      print('Erro geral: $e');
    }
  }
}
