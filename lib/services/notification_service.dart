import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Lembrete diário GENÉRICO (nunca revela a frase). Usa `periodicallyShow` com
/// repetição diária — sem fuso horário e sem permissão de alarme exato.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  static const int _dailyId = 1001;

  Future<void> init() async {
    if (_ready) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
    _ready = true;
  }

  /// Pede a permissão de notificações (Android 13+ / iOS). Retorna se concedida.
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? true;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(
              alert: true, badge: true, sound: true) ??
          true;
    }
    return true;
  }

  /// Agenda o lembrete diário (repete ~a cada 24h a partir de agora).
  Future<void> scheduleDaily({
    required String title,
    required String body,
  }) async {
    await init();
    await _plugin.periodicallyShow(
      _dailyId,
      title,
      body,
      RepeatInterval.daily,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quote',
          'Frase do dia',
          channelDescription: 'Lembrete diário de inspiração',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelDaily() => _plugin.cancel(_dailyId);
}
