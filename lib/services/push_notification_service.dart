import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/views/admin/notification_screen.dart';
import 'package:shop_app/views/home/widgets/alert_screen.dart';

class PushNotificationService {
  static const String _announcementTopic = 'kirana_store_announcements';

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static StreamSubscription<RemoteMessage>? _foregroundSubscription;
  static StreamSubscription<RemoteMessage>? _openedSubscription;

  static Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;
    try {
      if (!await messaging.isSupported()) {
        debugPrint('FCM is not supported on this platform.');
        return;
      }
    } catch (error) {
      debugPrint('FCM SUPPORT CHECK ERROR: $error');
      return;
    }

    try {
      await messaging.requestPermission();
      await messaging.subscribeToTopic(_announcementTopic);
    } catch (error) {
      debugPrint('FCM PERMISSION OR TOPIC SUBSCRIPTION ERROR: $error');
    }

    _foregroundSubscription ??=
        FirebaseMessaging.onMessage.listen(_showForegroundMessage);
    _openedSubscription ??=
        FirebaseMessaging.onMessageOpenedApp.listen(_openNotification);

    try {
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null && navigatorKey.currentState != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (navigatorKey.currentState != null) {
            _openNotification(initialMessage);
          }
        });
      }
    } catch (error) {
      debugPrint('FCM INITIAL MESSAGE ERROR: $error');
    }
  }

  static Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    _foregroundSubscription = null;
    _openedSubscription = null;
  }

  static void _showForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'New notification';
    final body =
        message.notification?.body ?? message.data['body']?.toString() ?? '';
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) {
      return;
    }

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(body.isEmpty ? title : '$title\n$body'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => _openNotification(message),
          ),
        ),
      );
  }

  static void _openNotification(RemoteMessage message) {
    final data = message.data;
    final audience = data['audience']?.toString();
    final role = data['role']?.toString();
    final isAdmin = audience == 'admin' || role == 'admin';
    final screen = isAdmin ? const NotificationScreen() : const AlertScreen();
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    navigator.push<void>(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }
}
