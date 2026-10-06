import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../screens/notifications_screen.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  factory NotificationService() => instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? navigatorKey;

  Future<void> init(GlobalKey<NavigatorState> navKey) async {
    navigatorKey = navKey;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Request permissions on Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  void _handleNotificationTap(String? payload) {
    if (payload == 'notifications_screen' && navigatorKey?.currentContext != null) {
      navigatorKey!.currentState?.push(
        MaterialPageRoute(builder: (_) => const NotificationsScreen()),
      );
    }
  }

  Future<void> showAdminRentDueNotification({
    required int count,
    required String tenantNamesSummary,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'admin_rent_due_channel',
      'Admin Rent Due Reminders',
      channelDescription: 'Notifications for admin when tenant rent is 14 days close to due',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Rent Due Reminder: $count tenant(s) at 14 days',
      tenantNamesSummary.isNotEmpty
          ? 'Tenants: $tenantNamesSummary. Tap to send reminders.'
          : 'Tap to view reminders and send notifications.',
      platformChannelSpecifics,
      payload: 'notifications_screen',
    );
  }

  Future<void> scheduleTenant14DayNotification({
    required int id,
    required String tenantName,
    required String houseLocation,
    required DateTime dueDate,
  }) async {
    // 14 days before due date at 9:00 AM
    final notificationDate = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day - 14,
      9,
      0,
      0,
    );

    if (notificationDate.isBefore(DateTime.now())) {
      return; // Already passed
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'admin_scheduled_rent_due_channel',
      'Admin Scheduled Rent Reminders',
      channelDescription: 'Scheduled notifications for admin when tenant rent is 14 days close to due',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(notificationDate, tz.local);

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Rent Due in 14 Days: $tenantName',
        'Tenant $tenantName at $houseLocation has 14 days until rent is due. Tap to send reminders.',
        tzScheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'notifications_screen',
      );
    } catch (_) {
      // Fallback if exact alarms permission is not granted
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
