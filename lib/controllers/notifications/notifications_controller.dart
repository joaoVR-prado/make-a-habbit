import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationsController {
  @pragma("vm:entry-point") // Necessário para funcionar em background!
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // TODO: Implementar click na notificao exeutar uma acao?
    //print('Usuário clicou na notificação: ${receivedAction.id}');
  }
}
