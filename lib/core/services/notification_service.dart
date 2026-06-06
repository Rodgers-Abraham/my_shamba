import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);
  }

  Future<void> scheduleMilestone(String title, String body, DateTime scheduledDate) async {
    await _notificationsPlugin.show(
      0, title, body,
      const NotificationDetails(android: AndroidNotificationDetails('farm_channel', 'Farm Notifications')),
    );
  }
}
