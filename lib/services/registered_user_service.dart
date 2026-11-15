import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/models/registered_user_model.dart';
import 'package:shop_app/services/api_config.dart';

class RegisteredUserService {
  RegisteredUserService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<RegisteredUserModel>> getUsers(AuthSession session) async {
    if (session.role != AccountRole.admin) {
      throw const RegisteredUserApiException(
        'An Admin account is required to select a registered user.',
      );
    }

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/users'),
      headers: {'Authorization': 'Bearer ${session.token}'},
    );
    if (response.statusCode != 200) {
      throw RegisteredUserApiException(
        _errorMessage(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const RegisteredUserApiException(
        'The Users API returned an unexpected response.',
      );
    }

    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const RegisteredUserApiException(
          'The Users API returned invalid user data.',
        );
      }
      return RegisteredUserModel.fromJson(item);
    }).toList();
  }

  void close() => _client.close();

  static String _errorMessage(int statusCode, String body) {
    final detail = _responseDetail(body);
    return switch (statusCode) {
      401 => 'Your session has expired. Please sign in again.',
      403 => 'Only an Admin account can load registered users.',
      404 => 'The registered-users API route was not found on the server.',
      _ => detail.isNotEmpty
          ? detail
          : 'Could not load registered users (HTTP $statusCode).',
    };
  }

  static String _responseDetail(String body) {
    if (body.trim().isEmpty) return '';
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return '';
      for (final key in ['detail', 'title', 'message', 'error']) {
        final value = decoded[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
    } on FormatException {
      return '';
    }
    return '';
  }
}

class RegisteredUserApiException implements Exception {
  const RegisteredUserApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
