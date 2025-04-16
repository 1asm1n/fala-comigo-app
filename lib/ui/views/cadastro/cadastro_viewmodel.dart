import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fala_comigo_app/app/app.locator.dart';
import 'package:fala_comigo_app/app/app.router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CadastroViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  // Controllers para pegar as infos do teclado
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

      // Salvar dados no Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'nome': nomeController.text.trim(),
        'email': emailController.text.trim(),
        'idade': idade,
        'menorDeIdade': menorDeIdade,
        'avatarUrl':
            'https://api.dicebear.com/7.x/initials/svg?seed=${nomeController.text.trim().replaceAll(' ', '+')}',
      });

      _navigationService.replaceWithHomeView();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
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
