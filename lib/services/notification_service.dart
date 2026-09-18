import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'إشعارات التطبيق الهامة',
    description: 'الإشعارات العامة والتنبيهات المهمة من التطبيق',
    importance: Importance.max,
    playSound: true,
  );

  static StreamSubscription<String>? _tokenSub;
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _local.initialize(settings);

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    final permission = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('🔔 Notification permission: ${permission.authorizationStatus}');

    // الاشتراك في Topic العام لاستقبال الإشعارات الجماعية
    try {
      await _messaging.subscribeToTopic('all');
      debugPrint('✅ Subscribed to topic: all');
    } catch (e) {
      debugPrint('❌ Failed to subscribe to topic all: $e');
    }

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('🔔 Opened notification: ${message.messageId}');
    });

    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      debugPrint('🔔 App opened from notification: ${initial.messageId}');
    }

    await registerCurrentUserToken();
    _tokenSub = _messaging.onTokenRefresh.listen((token) async {
      await _saveToken(token);
    });
  }

  static Future<void> registerCurrentUserToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.isAnonymous) return;
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _saveToken(token);
      }
    } catch (e) {
      debugPrint('🔔 FCM token registration failed: $e');
    }
  }

  static Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous || token.isEmpty) return;

    final key = token.hashCode.toUnsigned(32).toRadixString(16);
    final ref = FirebaseDatabase.instance.ref('users/${user.uid}/fcmTokens/$key');
    await ref.set({
      'token': token,
      'platform': 'android',
      'updatedAt': ServerValue.timestamp,
    });
  }

  static Future<void> removeCurrentUserTokens() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) return;
    try {
      await FirebaseDatabase.instance.ref('users/${user.uid}/fcmTokens').remove();
    } catch (e) {
      debugPrint('🔔 Failed to clear FCM tokens: $e');
    }
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString() ?? 'إشعار جديد 🔔';
    final body = notification?.body ?? message.data['body']?.toString() ?? '';

    await _local.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  static Future<void> dispose() async {
    await _tokenSub?.cancel();
    _tokenSub = null;
    _initialized = false;
  }
}
