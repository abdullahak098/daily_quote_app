// === lib/services/notification_service.dart ===
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);
    _scheduleDailyQuote();
  }

  Future<void> _scheduleDailyQuote() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_quote_channel',
      'Daily Quote',
      channelDescription: 'Shows a motivational quote daily',
      importance: Importance.max,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.periodicallyShow(
      0,
      'Quote of the Day',
      'Believe in yourself!', // Replace with dynamic quote later
      RepeatInterval.daily,
      platformDetails,
      androidAllowWhileIdle: true,
    );
  }
}
