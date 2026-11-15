import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/models/udhari_bill_model.dart';
import 'package:shop_app/models/udhar_model.dart';
import 'package:shop_app/services/api_config.dart';

class UdharService {
  UdharService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? _defaultBaseUrl).replaceFirst(RegExp(r'/$'), ''),
        _apiBaseUrl =
            (baseUrl ?? ApiConfig.baseUrl).replaceFirst(RegExp(r'/$'), '');

  static const _configuredBaseUrl =
      String.fromEnvironment('UDHAR_API_BASE_URL');

  static String get _defaultBaseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5023/api';
    }
    return 'http://localhost:5023/api';
  }

  final http.Client _client;
  final String _baseUrl;
  final String _apiBaseUrl;

  Uri get _collectionUri => Uri.parse('$_baseUrl/udhar');

  Future<List<UdhariBillModel>> getMyEntries(AuthSession session) async {
    if (session.role != AccountRole.user) {
      throw const UdharApiException('A User account is required.');
    }

    final response = await _client.get(
      Uri.parse('$_apiBaseUrl/Udhari/my'),
      headers: _headers(session),
    );
    _checkSuccess(response, const {200});
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const UdharApiException('The Udhari API returned invalid data.');
    }

    return decoded.map((item) {
      if (item is! Map<String, dynamic>) {
        throw const UdharApiException(
          'The Udhari API returned invalid entry data.',
        );
      }
      return UdhariBillModel.fromJson(item);
    }).toList();
  }

  Future<UdharModel> create(UdharModel entry, AuthSession session) async {
    final response = await _client.post(
      _collectionUri,
      headers: _headers(session),
      body: jsonEncode(entry.toCreateJson()),
    );
    _checkSuccess(response, const {200, 201});
    return UdharModel.fromJson(_decodeObject(response.body));
  }

  Future<List<UdharModel>> getAll(AuthSession session) async {
    final response = await _client.get(
      _collectionUri,
      headers: _headers(session),
    );
    _checkSuccess(response, const {200});
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const UdharApiException('The Udhar API returned invalid data.');
    }
    return decoded
        .map((item) => UdharModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<UdharModel> getById(int id, AuthSession session) async {
    final response = await _client.get(
      Uri.parse('${_collectionUri.toString()}/$id'),
      headers: _headers(session),
    );
    _checkSuccess(response, const {200});
    return UdharModel.fromJson(_decodeObject(response.body));
  }

  Future<List<UdharModel>> getForUser(
    int userId,
    AuthSession session,
  ) async {
    final response = await _client.get(
      Uri.parse('${_collectionUri.toString()}/user/$userId'),
      headers: _headers(session),
    );
    _checkSuccess(response, const {200});
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const UdharApiException('The Udhar API returned invalid data.');
    }
    return decoded
        .map((item) => UdharModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<UdharModel> update(
    int id,
    UdharModel entry,
    AuthSession session,
  ) async {
    final response = await _client.put(
      Uri.parse('${_collectionUri.toString()}/$id'),
      headers: _headers(session),
      body: jsonEncode(entry.toUpdateJson()),
    );
    _checkSuccess(response, const {200});
    return UdharModel.fromJson(_decodeObject(response.body));
  }

  Future<void> delete(int id, AuthSession session) async {
    final response = await _client.delete(
      Uri.parse('${_collectionUri.toString()}/$id'),
      headers: _headers(session),
    );
    _checkSuccess(response, const {204});
  }

  void close() => _client.close();

  Map<String, String> _headers(AuthSession session) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.token}',
      };

  static Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const UdharApiException('The Udhar API returned invalid data.');
    }
    return decoded;
  }

  static void _checkSuccess(http.Response response, Set<int> allowedStatuses) {
    if (allowedStatuses.contains(response.statusCode)) return;

    final message = _responseMessage(response.body);
    throw UdharApiException(
      message.isNotEmpty
          ? message
          : 'Udhar request failed (HTTP ${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }

  static String _responseMessage(String body) {
    if (body.trim().isEmpty) return '';
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return '';
      for (final key in ['detail', 'title', 'message', 'error']) {
        final value = decoded[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      final errors = decoded['errors'];
      if (errors is Map) {
        return errors.values
            .expand((value) => value is List ? value : [value])
            .map((value) => value.toString())
            .where((value) => value.isNotEmpty)
            .join(' ');
      }
    } on FormatException {
      return '';
    }
    return '';
  }
}

class UdharApiException implements Exception {
  const UdharApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
