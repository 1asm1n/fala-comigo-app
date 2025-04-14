import 'package:fala_comigo_app/app/app.locator.dart';
import 'package:fala_comigo_app/app/app.router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class CadastroViewModel extends BaseViewModel {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController =
      TextEditingController(); //pegando os campos email e senha com controllers
  String nome = '';
  String email = '';
  String senha = '';
  int idade = 0;
  bool menorDeIdade = false;
  final _navigationService = locator<NavigationService>();

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
        email: emailController
            .text, //pegando o conteudo do campo do email com o .text
        password: passwordController.text,
      );
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
}
