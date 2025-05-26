import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:package_info_plus/package_info_plus.dart';
import '../api_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    debugPrint('Initializing notification service...');

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification tapped: ${response.payload}');
        },
      );
      debugPrint('Notification service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
    }
  }

  Future<void> showFloodWarningNotification({
    required String title,
    required String body,
  }) async {
    debugPrint(
        'Attempting to show flood warning notification (Info Terbaru)...');

    const androidDetails = AndroidNotificationDetails(
      'flood_warning_channel',
      'Flood Warnings',
      channelDescription: 'Notifications about general flood warnings',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        notificationDetails,
        payload: 'flood_warning_info',
      );
      debugPrint(
          'Flood warning notification (Info Terbaru) shown successfully');
    } catch (e) {
      debugPrint('Error showing flood warning notification (Info Terbaru): $e');
    }
  }

  Future<void> showFloodEarlyWarningNotification({
    required String title,
    required String body,
  }) async {
    debugPrint(
        'Attempting to show flood early warning notification (Laporan)...');

    const androidDetails = AndroidNotificationDetails(
      'flood_early_warning_channel',
      'Flood Early Warnings',
      channelDescription:
          'Notifications about early flood warnings based on reports',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + 1,
        title,
        body,
        notificationDetails,
        payload: 'flood_early_warning_report',
      );
      debugPrint(
          'Flood early warning notification (Laporan) shown successfully');
    } catch (e) {
      debugPrint(
          'Error showing flood early warning notification (Laporan): $e');
    }
  }

  Future<void> showWeatherWarningNotification({
    required String title,
    required String body,
  }) async {
    debugPrint('Attempting to show weather warning notification...');

    const androidDetails = AndroidNotificationDetails(
      'weather_warning_channel',
      'Weather Warnings',
      channelDescription: 'Notifications about weather warnings',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + 2,
        title,
        body,
        notificationDetails,
        payload: 'weather_warning',
      );
      debugPrint('Weather warning notification shown successfully');
    } catch (e) {
      debugPrint('Error showing weather warning notification: $e');
    }
  }

  Future<DateTime> getInstallDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final installDateStr = prefs.getString('app_install_date');

      if (installDateStr == null) {
        final now = DateTime.now();
        await prefs.setString('app_install_date', now.toIso8601String());
        return now;
      }

      return DateTime.parse(installDateStr);
    } catch (e) {
      debugPrint('Error getting install date: $e');
      return DateTime.now();
    }
  }

  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    try {
      final installDate = await getInstallDate();
      final response = await ApiService.getNotificationHistory();
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching notification history: $e');
      return [];
    }
  }
}
