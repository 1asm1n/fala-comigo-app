import 'package:patrol/patrol.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:fala_comigo_app/main.dart';

void main() {
  patrolTest(
      'fluxo de login: verifica campos, preenche, clica e navega para Home',
      ($) async {
    await $.pumpWidgetAndSettle(const MainApp());

    // testando email
    expect($(#login_email_field), findsOneWidget);
    expect($(#login_password_field), findsOneWidget);
    expect($(#login_button), findsOneWidget);

    // testando preenchimentos
    await $(#login_email_field).enterText('usuario@teste.com');
    await $(#login_password_field).enterText('senha123');

    // botao de login
    await $(#login_button).tap();
    await $.pumpAndSettle();

    // testa se foi pra home com texto chats
    expect($(Text('Chats')), findsOneWidget);
  });
}
