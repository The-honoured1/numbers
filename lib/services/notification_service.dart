import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    
    final AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    await scheduleReminders();
  }

  Future<void> scheduleReminders() async {
    // Cancel existing to avoid duplicates
    await _notifications.cancelAll();

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_reminder',
      'Daily Reminders',
      channelDescription: 'Reminders to play the game every 3 hours',
      importance: Importance.high,
      priority: Priority.high,
    );

    final NotificationDetails details = NotificationDetails(android: androidDetails);

    // Schedule 3-hour interval (simplified: schedule multiple for the next 24h)
    for (int i = 1; i <= 8; i++) {
      await _notifications.zonedSchedule(
        i,
        'Time for a challenge!',
        'The numbers are waiting for you! Can you beat your high score?',
        tz.TZDateTime.now(tz.local).add(Duration(hours: 3 * i)),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}
