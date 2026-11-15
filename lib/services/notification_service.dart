import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/services/api_config.dart';
import 'package:shop_app/services/local_notification_service.dart';

class NotificationService {
  NotificationService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<LocalAppNotification>> getMyNotifications(
    AuthSession session,
  ) async {
    if (session.role != AccountRole.user) {
      throw const NotificationApiException(
        'A User account is required to load personal notifications.',
      );
    }

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/Notification/my'),
      headers: {'Authorization': 'Bearer ${session.token}'},
    );
    if (response.statusCode != 200) {
      throw NotificationApiException(
        _errorMessage(response.statusCode),
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const NotificationApiException(
        'The Notifications API returned an unexpected response.',
      );
    }
    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const NotificationApiException(
          'The Notifications API returned invalid notification data.',
        );
      }
      return LocalAppNotification.fromJson({
        ...item,
        'audience': 'user',
        'message': item['message'] ?? item['body'] ?? '',
        'createdAt':
            item['createdAt'] ?? item['createdAtUtc'] ?? item['sentAt'] ?? '',
      });
    }).toList()
      ..sort((first, second) => second.createdAt.compareTo(first.createdAt));
  }

  void close() => _client.close();

  static String _errorMessage(int statusCode) => switch (statusCode) {
        401 => 'Your session has expired. Please sign in again.',
        403 => 'You do not have permission to view these notifications.',
        404 => 'The Notifications API route was not found on the server.',
        _ => 'Could not load notifications (HTTP $statusCode).',
      };
}

class NotificationApiException implements Exception {
  const NotificationApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
