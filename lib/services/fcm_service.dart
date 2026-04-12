import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:to_do_list/utils/notification_service.dart';

/// Top-level handler for background / terminated-state FCM messages.
/// Must be a top-level function (not a class method) per Firebase docs.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('[FCM] Background message: ${message.messageId}');
}

/// Singleton service that initialises Firebase Cloud Messaging,
/// requests permission, retrieves the device token, and relays
/// foreground messages to [NotificationService] for display.
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final _messaging = FirebaseMessaging.instance;
  bool _initialized = false;

  /// The FCM notification channel shown for foreground messages.
  static const _channel = AndroidNotificationChannel(
    'fcm_default', // must match AndroidManifest meta-data value
    'Push Notifications',
    description: 'Notifications received from Firebase Cloud Messaging',
    importance: Importance.high,
  );

  /// Call once after [Firebase.initializeApp].
  Future<void> init() async {
    if (_initialized) return;

    // 1. Request permission (Android 13+ / iOS)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    log('[FCM] Permission status: ${settings.authorizationStatus}');

    // 2. Create the Android notification channel
    final plugin = FlutterLocalNotificationsPlugin();
    await plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 3. Get & log the FCM token (use this in Firebase Console → Send test)
    try {
      final token = await _messaging.getToken();
      log('[FCM] Device token: $token');
    } catch (e) {
      log('[FCM] Could not get token: $e');
    }

    // 4. Listen to token refreshes
    _messaging.onTokenRefresh.listen((newToken) {
      log('[FCM] Token refreshed: $newToken');
    });

    // 5. Foreground messages → show as local notification
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. When user taps a background notification to open the app
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('[FCM] Notification tapped (background): ${message.data}');
    });

    // 7. Check if the app was opened from a terminated-state notification
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      log('[FCM] Opened from terminated notification: ${initial.data}');
    }

    _initialized = true;
  }

  /// Display a foreground FCM message using the local notification plugin.
  void _handleForegroundMessage(RemoteMessage message) {
    log('[FCM] Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    if (notification == null) return;

    final plugin = FlutterLocalNotificationsPlugin();
    plugin.show(
      notification.hashCode,
      notification.title ?? 'New Notification',
      notification.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}
