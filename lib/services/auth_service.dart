import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/auth_session.dart';
import 'api_config.dart';

abstract interface class AuthSessionStore {
  Future<void> save(AuthSession session);
  Future<AuthSession?> read();
  Future<void> clear();
}

class SecureAuthSessionStore implements AuthSessionStore {
  SecureAuthSessionStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth.jwt';
  static const _emailKey = 'auth.email';
  static const _roleKey = 'auth.role';
  static const _shopNameKey = 'auth.shopName';

  final FlutterSecureStorage _storage;

  @override
  Future<void> save(AuthSession session) async {
    await _storage.write(key: _tokenKey, value: session.token);
    await _storage.write(key: _emailKey, value: session.email);
    await _storage.write(key: _roleKey, value: session.role.apiValue);
    if (session.shopName == null || session.shopName!.isEmpty) {
      await _storage.delete(key: _shopNameKey);
    } else {
      await _storage.write(key: _shopNameKey, value: session.shopName);
    }
  }

  @override
  Future<AuthSession?> read() async {
    final token = await _storage.read(key: _tokenKey);
    final email = await _storage.read(key: _emailKey);
    final role = AccountRole.fromApi(await _storage.read(key: _roleKey));
    if (token == null || token.isEmpty || email == null || role == null) {
      return null;
    }

    return AuthSession(
      token: token,
      email: email,
      role: role,
      shopName: await _storage.read(key: _shopNameKey),
    );
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _emailKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _shopNameKey);
  }
}

class AuthService {
  AuthService({
    http.Client? client,
    AuthSessionStore? sessionStore,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _sessionStore = sessionStore ?? SecureAuthSessionStore(),
        _baseUrl =
            (baseUrl ?? ApiConfig.baseUrl).replaceFirst(RegExp(r'/$'), '');

  final http.Client _client;
  final AuthSessionStore _sessionStore;
  final String _baseUrl;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/Auth/login'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );
    _checkSuccess(response,
        unauthorizedMessage: 'Email or password is incorrect.');

    final decoded = _decodeObject(response.body);
    final user = decoded['user'];
    final userData = user is Map<String, dynamic> ? user : <String, dynamic>{};
    final token = decoded['token']?.toString() ?? '';
    final role = AccountRole.fromApi(userData['role']?.toString());
    if (token.isEmpty || role == null) {
      throw const AuthApiException(
        'The login response is missing a valid token or account role.',
      );
    }

    final session = AuthSession(
      token: token,
      email: userData['email']?.toString() ?? email.trim(),
      role: role,
      shopName: userData['shopName']?.toString(),
    );
    await _sessionStore.save(session);
    return session;
  }

  Future<void> registerUser({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/Auth/register/user'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.trim(), 'password': password}),
    );
    _checkSuccess(response);
  }

  Future<void> registerAdmin({
    required String shopName,
    required String email,
    required String password,
    required String setupKey,
  }) async {
    final response = await _client.post(
      Uri.parse('$_baseUrl/Auth/register/admin'),
      headers: {
        'Content-Type': 'application/json',
        'X-Admin-Registration-Key': setupKey,
      },
      body: jsonEncode({
        'shopName': shopName.trim(),
        'email': email.trim(),
        'password': password,
      }),
    );
    _checkSuccess(
      response,
      unauthorizedMessage: 'The admin setup key is invalid.',
    );
  }

  Future<AuthSession?> readSession() => _sessionStore.read();

  Future<void> logout() => _sessionStore.clear();

  void close() => _client.close();

  static Map<String, dynamic> _decodeObject(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const AuthApiException(
        'The authentication API returned invalid data.',
      );
    }
    return decoded;
  }

  static void _checkSuccess(
    http.Response response, {
    String? unauthorizedMessage,
  }) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;

    final detail = _responseDetail(response.body);
    final message = switch (response.statusCode) {
      400 => _withDetail('Please check the submitted fields.', detail),
      401 => unauthorizedMessage ?? 'Authentication was rejected.',
      409 => detail.isNotEmpty
          ? detail
          : 'This account or shop admin is already registered.',
      503 => 'Admin setup is not configured on the server.',
      _ => detail.isNotEmpty
          ? detail
          : 'The request failed (HTTP ${response.statusCode}).',
    };
    throw AuthApiException(message, statusCode: response.statusCode);
  }

  static String _responseDetail(String body) {
    if (body.trim().isEmpty) return '';
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return '';
      for (final key in ['message', 'detail', 'title', 'error']) {
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

  static String _withDetail(String message, String detail) =>
      detail.isEmpty ? message : '$message $detail';
}

class AuthApiException implements Exception {
  const AuthApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
