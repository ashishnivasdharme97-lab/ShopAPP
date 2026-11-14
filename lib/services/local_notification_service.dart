import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalAppNotification {
  final String id;
  final String audience;
  final String title;
  final String message;
  final DateTime createdAt;

  const LocalAppNotification({
    required this.id,
    required this.audience,
    required this.title,
    required this.message,
    required this.createdAt,
  });

  factory LocalAppNotification.fromJson(Map<String, dynamic> json) {
    return LocalAppNotification(
      id: json['id']?.toString() ?? '',
      audience: json['audience']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'audience': audience,
        'title': title,
        'message': message,
        'createdAt': createdAt.toIso8601String(),
      };
}

class LocalNotificationService {
  static const _storageKey = 'local_app_notifications';

  static Future<List<LocalAppNotification>> getForAudience(
    String audience,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_storageKey) ?? [];
    final notifications = stored
        .map((entry) => LocalAppNotification.fromJson(
              jsonDecode(entry) as Map<String, dynamic>,
            ))
        .where((notification) => notification.audience == audience)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    await preferences.setStringList(
      _storageKey,
      stored.take(100).toList(),
    );

    return notifications;
  }

  static Future<void> add({
    required String audience,
    required String title,
    required String message,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_storageKey) ?? [];
    final notification = LocalAppNotification(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      audience: audience,
      title: title,
      message: message,
      createdAt: DateTime.now(),
    );
    stored.insert(0, jsonEncode(notification.toJson()));
    await preferences.setStringList(_storageKey, stored.take(100).toList());
  }

  static Future<void> ensureFestivalReminderSevenDaysBefore({
    required String festivalName,
    required DateTime festivalDate,
    required String audience,
  }) async {
    final now = DateTime.now();
    final reminderStart = festivalDate.subtract(const Duration(days: 7));
    final reminderEnd = festivalDate.add(const Duration(days: 1));

    final isWithinReminderWindow = !now.isBefore(reminderStart) &&
        now.isBefore(reminderEnd);
    if (!isWithinReminderWindow) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_storageKey) ?? [];
    final message =
        '$festivalName starts in 7 days. Check the latest festive offers now.';

    final alreadyAdded = stored.any((entry) {
      try {
        final notification = LocalAppNotification.fromJson(
          jsonDecode(entry) as Map<String, dynamic>,
        );
        return notification.audience == audience &&
            notification.title == festivalName &&
            notification.message == message;
      } catch (_) {
        return false;
      }
    });

    if (alreadyAdded) {
      return;
    }

    final notification = LocalAppNotification(
      id: 'festival_${festivalName}_${audience}_${festivalDate.year}${festivalDate.month}${festivalDate.day}',
      audience: audience,
      title: festivalName,
      message: message,
      createdAt: now,
    );

    stored.insert(0, jsonEncode(notification.toJson()));
    await preferences.setStringList(_storageKey, stored.take(100).toList());
  }
}
