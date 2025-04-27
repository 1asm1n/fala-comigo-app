import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fala_comigo_app/app/app.bottomsheets.dart';
import 'package:fala_comigo_app/app/app.dialogs.dart';
import 'package:fala_comigo_app/app/app.locator.dart';
import 'package:fala_comigo_app/app/app.router.dart';
import 'package:stacked_services/stacked_services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Carrega as variáveis de ambiente primeiro
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('Variáveis de ambiente carregadas com sucesso.');
  } catch (e) {
    debugPrint('Erro ao carregar o .env: $e');
  }

  // Inicializa Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase inicializado com sucesso.');
  } catch (e) {
    debugPrint('Erro ao inicializar o Firebase: $e');
  }

  // Inicializa serviços do app
  await setupLocator();
  setupDialogUi();
  setupBottomSheetUi();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: Routes.startupView,
      onGenerateRoute: StackedRouter().onGenerateRoute,
      navigatorKey: StackedService.navigatorKey,
      navigatorObservers: [StackedService.routeObserver],
    );
  }
}
