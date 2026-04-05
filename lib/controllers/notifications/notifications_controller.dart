import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationsController {
  @pragma("vm:entry-point") // Necessário para funcionar em background!
  static Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // TODO: Implementar click na notificao exeutar uma acao?
    //print('Usuário clicou na notificação: ${receivedAction.id}');
  }

  // Controle para deletarmos as notificacoes ao deletar o habito
  static Future<void> deleteHabitNotifications(int baseNotificationId) async{
    final awesome = AwesomeNotifications();

    // Cancela lembrete
    await awesome.cancel(baseNotificationId);

    // Cancela lembretes semanais
    for (int i = 1; i <= 7; i++) {
      await awesome.cancel(baseNotificationId + i);

    }

    // Cancela lembretes mensais
    for (int i = 1; i <= 31; i++) {
      await awesome.cancel(baseNotificationId + i + 100);

    }

    // Cancela Streak
    await awesome.cancel(baseNotificationId + 10000);

  }


}
