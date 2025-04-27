import 'package:fala_comigo_app/app/app.locator.dart';
import 'package:fala_comigo_app/app/app.router.dart';
import 'package:fala_comigo_app/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:fala_comigo_app/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:fala_comigo_app/ui/views/home/home_view.dart';
import 'package:fala_comigo_app/ui/views/startup/startup_view.dart';
import 'package:fala_comigo_app/ui/views/login/login_view.dart';
import 'package:fala_comigo_app/ui/views/cadastro/cadastro_view.dart';
import 'package:fala_comigo_app/ui/views/chat/chat_view.dart';
import 'package:fala_comigo_app/ui/views/chatbot/chatbot_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';

// Importações para o Firebase (adicione o arquivo de configuração apropriado)
import '../firebase_options.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView, name: 'home'),
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: LoginView, name: 'login'),
    MaterialRoute(page: CadastroView, name: 'cadastro'),
    MaterialRoute(page: ChatView, path: '/chat-view'),
    MaterialRoute(page: ChatbotView, name: 'chatbot'),
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    LazySingleton(
        classType: SnackbarService), // Adicionado para feedback visual
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
  ],
)
class App {
  // Adicione esta função main atualizada
  static Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Inicialize o Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Configure os locators do Stacked
    await setupLocator();

    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fala Comigo',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      initialRoute: Routes.startupView,
    );
  }
}
