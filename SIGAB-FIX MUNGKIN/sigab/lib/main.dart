import 'package:flutter/material.dart';
import 'package:sigab/services/notification_service.dart';
import 'package:sigab/api_service.dart';
import 'dart:async';
import 'screens/registration_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/banjir_screen.dart';
import 'screens/cuaca_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/lapor_screen.dart';
import 'screens/lainnya_screen.dart';
import 'screens/detail_riwayat_banjir_screen.dart';
import 'screens/detail_tips_mitigasi_screen.dart';
import 'screens/tempat_evakuasi_screen.dart';
import 'screens/tips_mitigasi_screen.dart';
import 'screens/laporan_banjir_screen.dart';
import 'screens/laporan_infrastruktur_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().initialize();
  debugPrint('Notification service initialized');

  // Get installation date (will be saved if not exists)
  final installDate = await NotificationService().getInstallDate();
  debugPrint('App installed on: $installDate');

  // Request notification permissions for Android 13+ (API 33+)
  // For iOS, permission is typically requested during initialize() if configured.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  if (androidImplementation != null) {
    // requestPermission() hanya tersedia di Android 13+ (API 33+).
    // Plugin secara internal akan mengecek versi Android.
    try {
      final bool? granted = await androidImplementation.requestPermission();
      debugPrint('Android notification permission granted: $granted');
    } catch (e) {
      debugPrint('Error requesting Android notification permission: $e');
    }
  }

  // Untuk iOS/macOS, asumsikan inisialisasi sudah menangani permintaan izin
  // berdasarkan konfigurasi di NotificationService. DarwinInitializationSettings
  // sudah diatur untuk meminta izin. Jika perlu debug, cek log inisialisasi.
  debugPrint(
      'iOS/macOS permission is handled during NotificationService initialization.');

  // Start periodic notification check
  Timer.periodic(const Duration(seconds: 5), (timer) async {
    // debugPrint('DEBUG: Timer periodic callback triggered.');
    try {
      // debugPrint('DEBUG: Entered periodic try block.');
      // --- Logika cek notifikasi 3 laporan valid ---
      // debugPrint('Checking flood reports for early warning...');
      // debugPrint('DEBUG Reports: Calling ApiService.checkFloodReports()');
      final dataReports = await ApiService.checkFloodReports();
      // debugPrint(
      //     'DEBUG Reports: Received response from ApiService.checkFloodReports()');
      // debugPrint('Flood reports response: $dataReports');

      if (dataReports['data'] != null && dataReports['data']['should_notify']) {
        debugPrint(
            'Early Warning Notification Status: Should notify (from reports): true');
        final prefs = await SharedPreferences.getInstance();
        // Menggunakan key shared_preferences yang berbeda untuk notifikasi laporan
        final lastNotificationDate =
            prefs.getString('lastFloodNotificationDateReports');
        final today = DateTime.now()
            .toLocal()
            .toIso8601String()
            .split('T')[0]; // Get today\'s date string (YYYY-MM-DD)

        // debugPrint(
        //     'DEBUG Reports: lastNotificationDate from prefs: $lastNotificationDate');
        // debugPrint('DEBUG Reports: today calculated: $today');
        // debugPrint(
        //     'DEBUG Reports: Comparison lastNotificationDate != today: ${lastNotificationDate != today}');

        if (lastNotificationDate != today) {
          debugPrint('Early Warning: Showing notification now...');
          await NotificationService().showFloodEarlyWarningNotification(
            title: 'Peringatan Dini Banjir',
            body:
                'Terdapat 3 laporan banjir valid hari ini. Mohon waspada dan perhatikan informasi lebih lanjut.',
          );
          // Save today\'s date to shared preferences for reports
          await prefs.setString('lastFloodNotificationDateReports', today);
          debugPrint('Early Warning: Saved last notification date: $today');
        } else {
          debugPrint(
              'Early Warning: Notification already shown today, skipping.');
        }
      } else {
        debugPrint(
            'Early Warning Notification Status: Should notify (from reports): false');
      }
      // --- Akhir logika cek notifikasi 3 laporan valid ---

      // --- Logika cek notifikasi informasi banjir terbaru ---
      // debugPrint('Checking for latest flood information...');
      final latestInfo = await ApiService.getLatestFloodInfo();
      // debugPrint('Latest flood info response: $latestInfo');

      if (latestInfo != null) {
        final prefs = await SharedPreferences.getInstance();
        // Menggunakan key shared_preferences yang berbeda untuk notifikasi info terbaru
        final lastNotificationTimestamp =
            prefs.getString('lastFloodInfoNotificationTimestamp');
        final currentInfoTimestamp =
            latestInfo['created_at']; // Ambil timestamp dari data terbaru

        // debugPrint(
        //     'DEBUG Info: lastNotificationTimestamp from prefs: $lastNotificationTimestamp');
        // debugPrint(
        //     'DEBUG Info: currentInfoTimestamp from API: $currentInfoTimestamp');
        // debugPrint(
        //     'DEBUG Info: Comparison lastNotificationTimestamp != currentInfoTimestamp: ${lastNotificationTimestamp != currentInfoTimestamp}');

        if (lastNotificationTimestamp != currentInfoTimestamp) {
          debugPrint(
              'Latest Flood Info: New information detected, showing notification...');
          await NotificationService().showFloodWarningNotification(
            title: 'Informasi Banjir Terbaru',
            body:
                'Banjir terdeteksi di wilayah ${latestInfo['wilayah_banjir'] ?? 'Tidak Diketahui'}. Mohon waspada.',
          );
          // Save the timestamp of the latest info
          await prefs.setString(
              'lastFloodInfoNotificationTimestamp', currentInfoTimestamp);
          debugPrint(
              'Latest Flood Info: Saved latest info timestamp: $currentInfoTimestamp');
        } else {
          debugPrint(
              'Latest Flood Info: No new information, skipping notification.');
        }
      } else {
        debugPrint('Latest Flood Info: No flood information found.');
      }
      // --- Akhir logika cek notifikasi informasi banjir terbaru ---
    } catch (e, stacktrace) {
      debugPrint('ERROR IN PERIODIC CHECK: $e');
      // debugPrint('STACKTRACE: $stacktrace');
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIGAB',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      initialRoute: '/home',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegistrationScreen(),
        '/': (context) => const MainScreen(),
        '/banjir': (context) => const BanjirScreen(),
        '/cuaca': (context) => const CuacaScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),
        '/lapor': (context) => const LaporScreen(),
        '/lainnya': (context) => const LainnyaScreen(),
        '/detail-riwayat-banjir': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return DetailRiwayatBanjirScreen(
            date: args['date'],
            time: args['time'],
            location: args['location'],
            depth: args['depth'],
            statusColor: args['statusColor'],
            status: args['status'],
            coordinates: args['coordinates'],
          );
        },
        '/detail-tips-mitigasi': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return DetailTipsMitigasiScreen(
            title: args['title'],
            imagePath: args['imagePath'],
            tipsList: args['tipsList'],
          );
        },
        '/tempat-evakuasi': (context) => const TempatEvakuasiScreen(),
        '/tips-mitigasi': (context) => const TipsMitigasiScreen(),
        '/laporan_banjir': (context) => const LaporanBanjirScreen(),
        '/laporan_infrastruktur': (context) =>
            const LaporanInfrastrukturScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
