import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // Не иницијализирај нотификации на Web
    if (kIsWeb) {
      print('Notifications are not supported on Web platform');
      return;
    }

    // Request notification permissions (Android 13+)
    await _requestPermissions();

    // Initialize timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Skopje'));

    // Android initialization
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification tapped: ${details.payload}');
      },
    );

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'meal_channel',
      'Meal Notifications',
      description: 'Нотификации за рецепти',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Request permissions for iOS and FCM
    NotificationSettings fcmSettings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    print('FCM Permission status: ${fcmSettings.authorizationStatus}');

    // Get FCM token
    String? token = await _messaging.getToken();
    print('FCM Token: $token');

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.notification?.title}');
      if (message.notification != null) {
        _showNotification(
          message.notification?.title ?? 'Нова нотификација',
          message.notification?.body ?? '',
        );
      }
    });

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notification opened from background: ${message.notification?.title}');
    });

    // Handle initial message (when app opens from terminated state)
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('App opened from terminated state via notification');
    }

    // Schedule daily notification for random recipe
    // await scheduleDailyRandomRecipeNotification();
  }

  // Request notification permissions
  static Future<void> _requestPermissions() async {
    if (await Permission.notification.isDenied) {
      final status = await Permission.notification.request();
      print('Notification permission status: $status');
    }

    // Request exact alarm permission for Android 12+
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      print('Exact alarm permission status: $status');
    }
  }

  // Show immediate notification
  static Future<void> _showNotification(String title, String body) async {
    if (kIsWeb) return;

    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'meal_channel',
      'Meal Notifications',
      channelDescription: 'Нотификации за рецепти',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
      );
      print('Notification shown: $title - $body');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // Schedule daily notification at specific time (10:00 AM)
  static Future<void> scheduleDailyRandomRecipeNotification() async {
    if (kIsWeb) return;

    try {
      await _notifications.zonedSchedule(
        1,
        '🍽️ Рецепт на денот!',
        'Погледнете го случајниот рецепт за денес!',
        _nextInstanceOfTime(10, 0), // 10:00 AM
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_recipe_channel',
            'Daily Recipe',
            channelDescription: 'Дневна нотификација за рецепт',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('Daily notification scheduled for 10:00 AM');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Send test notification (за debug)
  static Future<void> sendTestNotification() async {
    if (kIsWeb) {
      print('Test notification: Notifications are not supported on Web');
      return;
    }

    print('Sending test notification...');
    await _showNotification(
      '🔔 Тест нотификација',
      'Ако ја гледате оваа порака, нотификациите работат! ✅',
    );
  }

  // Schedule immediate test notification (after 5 seconds)
  static Future<void> scheduleTestNotification() async {
    if (kIsWeb) return;

    final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    await _notifications.zonedSchedule(
      999,
      '⏰ Закажана нотификација',
      'Ова е тест на закажана нотификација!',
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test Notifications',
          channelDescription: 'Тест нотификации',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );

    print('Test notification scheduled for 5 seconds from now');
  }

  // Check notification permissions
  static Future<bool> areNotificationsEnabled() async {
    if (kIsWeb) return false;

    final status = await Permission.notification.status;
    print('Current notification permission: $status');
    return status.isGranted;
  }
}