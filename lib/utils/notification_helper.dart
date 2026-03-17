import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationHelper {
  static final NotificationHelper instance = NotificationHelper._internal();
  NotificationHelper._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher_foreground');

    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {},
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'money_tracker_channel',
      'Money Tracker',
      channelDescription: 'Moliyaviy eslatmalar',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher_foreground',
    );

    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, title, body, details);
  }

  Future<void> scheduleMonthlyNotification({
    required int id,
    required String title,
    required String body,
    required int dayOfMonth,
    required int hour,
    required int minute,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'money_tracker_reminder',
      'Eslatmalar',
      channelDescription: 'Oylik to\'lov eslatmalari',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher_foreground',
    );

    const details = NotificationDetails(android: androidDetails);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      dayOfMonth,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = tz.TZDateTime(
        tz.local,
        now.year,
        now.month + 1,
        dayOfMonth,
        hour,
        minute,
      );
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  Future<void> checkAndSendTodayReminders(
      List<Map<String, dynamic>> reminders) async {
    final today = DateTime.now().day;

    for (final reminder in reminders) {
      if (reminder['day_of_month'] == today &&
          reminder['is_active'] == 1) {
        final isIncome = reminder['type'] == 'kirim';
        final amount = (reminder['amount'] as num).toDouble();
        final amountStr = amount
            .toStringAsFixed(0)
            .replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (m) => '${m[1]} ');

        await showNotification(
          id: reminder['id'] as int,
          title: isIncome ? 'Kirim eslatmasi' : 'Chiqim eslatmasi',
          body: '${reminder['title']} — $amountStr so\'m bugun!',
        );
      }
    }
  }

  Future<void> scheduleReminderNotification({
    required int id,
    required String title,
    required double amount,
    required String type,
    required int dayOfMonth,
  }) async {
    final isIncome = type == 'kirim';
    final amountStr = amount
        .toStringAsFixed(0)
        .replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (m) => '${m[1]} ');

    await scheduleMonthlyNotification(
      id: id,
      title: isIncome ? 'Kirim eslatmasi' : 'Chiqim eslatmasi',
      body: '$title — $amountStr so\'m',
      dayOfMonth: dayOfMonth,
      hour: 9,
      minute: 0,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }
}
