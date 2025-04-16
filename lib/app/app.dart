import 'package:fala_comigo_app/ui/bottom_sheets/notice/notice_sheet.dart';
import 'package:fala_comigo_app/ui/dialogs/info_alert/info_alert_dialog.dart';
import 'package:fala_comigo_app/ui/views/home/home_view.dart';
import 'package:fala_comigo_app/ui/views/startup/startup_view.dart';
import 'package:fala_comigo_app/ui/views/login/login_view.dart';
import 'package:fala_comigo_app/ui/views/cadastro/cadastro_view.dart';
import 'package:fala_comigo_app/ui/views/chat/chat_view.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
// @stacked-import

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView),
    MaterialRoute(page: StartupView, initial: true),
    MaterialRoute(page: LoginView),
    MaterialRoute(page: CadastroView),
    MaterialRoute(page: ChatView, path: '/chat-view'),
    // @stacked-route
  ],
  dependencies: [
    LazySingleton(classType: BottomSheetService),
    LazySingleton(classType: DialogService),
    LazySingleton(classType: NavigationService),
    // @stacked-service
  ],
  bottomsheets: [
    StackedBottomsheet(classType: NoticeSheet),
    // @stacked-bottom-sheet
  ],
  dialogs: [
    StackedDialog(classType: InfoAlertDialog),
    // @stacked-dialog
  ],
)
class App {}
