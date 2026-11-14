import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/auth_session.dart';
import '../models/create_pending_model.dart';
import '../models/pending_model.dart';
import 'api_config.dart';

class PendingService {
  static String get baseUrl => '${ApiConfig.baseUrl}/Pending';

  static Future<List<PendingModel>> getPendingForAdmin(
    AuthSession session,
  ) async {
    if (session.role != AccountRole.admin) {
      throw const PendingApiException('An Admin account is required.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/admin'),
      headers: {'Authorization': 'Bearer ${session.token}'},
    );
    return _decodePendings(response);
  }

  static Future<List<PendingModel>> getPendingForUser(
    AuthSession session,
  ) async {
    if (session.role != AccountRole.user) {
      throw const PendingApiException('A User account is required.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/my'),
      headers: {'Authorization': 'Bearer ${session.token}'},
    );
    return _decodePendings(response);
  }

  static Future<List<PendingModel>> getPendingForCustomer(
    String customerName,
    AuthSession session,
  ) async {
    if (session.role != AccountRole.admin) {
      throw const PendingApiException('An Admin account is required.');
    }
    final encodedName = Uri.encodeComponent(customerName.trim());
    final response = await http.get(
      Uri.parse('$baseUrl/admin/customer/$encodedName'),
      headers: {'Authorization': 'Bearer ${session.token}'},
    );
    return _decodePendings(response);
  }

  static List<PendingModel> _decodePendings(http.Response response) {
    if (response.statusCode != 200) {
      throw PendingApiException(_errorMessage(response.statusCode));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const PendingApiException(
        "The Udhari API returned an unexpected response.",
      );
    }

    return decoded
        .map((item) => PendingModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static String _errorMessage(int statusCode) => switch (statusCode) {
        401 => 'Your session has expired. Please sign in again.',
        403 => 'This account does not have permission to view these records.',
        404 => 'The Pending API route was not found on the server.',
        _ => 'Could not load Udhari records (HTTP $statusCode).',
      };

  static Future<bool> addPending(CreatePendingModel model) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(model.toJson()),
    );

    return response.statusCode == 200;
  }
}

class PendingApiException implements Exception {
  final String message;

  const PendingApiException(this.message);

  @override
  String toString() => message;
}
