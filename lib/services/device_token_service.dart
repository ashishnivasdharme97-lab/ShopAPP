import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/services/api_config.dart';

class DeviceTokenService {
  DeviceTokenService({
    FirebaseMessaging? messaging,
    http.Client? client,
    String? baseUrl,
  })  : _messagingOverride = messaging,
        _client = client ?? http.Client(),
        _baseUrl =
            (baseUrl ?? ApiConfig.baseUrl).replaceFirst(RegExp(r'/$'), '');

  final FirebaseMessaging? _messagingOverride;
  final http.Client _client;
  final String _baseUrl;

  FirebaseMessaging get _messaging =>
      _messagingOverride ?? FirebaseMessaging.instance;

  StreamSubscription<String>? _tokenRefreshSubscription;
  AuthSession? _activeSession;

  Uri get _registerUri => Uri.parse('$_baseUrl/device-tokens/register');
  Uri get _unregisterUri => Uri.parse('$_baseUrl/device-tokens/unregister');

  Future<void> registerForSession(AuthSession session) async {
    _activeSession = session;
    if (!await _messaging.isSupported()) {
      debugPrint('Device push registration is not supported on this platform.');
      return;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      debugPrint('Push notification permission was not granted.');
      return;
    }

    // The existing API sends to FCM registration tokens, not Firebase
    // Installation IDs emitted by onRegistered.
    // ignore: deprecated_member_use
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) {
      debugPrint('Firebase did not provide a device token.');
      return;
    }

    await _registerToken(token, session);
    // ignore: deprecated_member_use
    _tokenRefreshSubscription ??= _messaging.onTokenRefresh.listen(
      (refreshedToken) {
        final activeSession = _activeSession;
        if (activeSession == null) return;
        unawaited(_registerRefreshedToken(refreshedToken, activeSession));
      },
    );
  }

  Future<void> unregisterForSession(AuthSession session) async {
    _activeSession = null;
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;

    if (!await _messaging.isSupported()) return;

    // ignore: deprecated_member_use
    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;

    final response = await _client.delete(
      _unregisterUri,
      headers: _headers(session),
      body: jsonEncode({'token': token}),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw DeviceTokenApiException(
        'Could not unregister this device (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
  }

  Future<void> _registerRefreshedToken(
    String token,
    AuthSession session,
  ) async {
    try {
      await _registerToken(token, session);
    } catch (error) {
      debugPrint('Could not register refreshed device token: $error');
    }
  }

  Future<void> _registerToken(String token, AuthSession session) async {
    final response = await _client.post(
      _registerUri,
      headers: _headers(session),
      body: jsonEncode({'token': token}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw DeviceTokenApiException(
        'Could not register this device (HTTP ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }
  }

  Map<String, String> _headers(AuthSession session) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${session.token}',
      };

  Future<void> dispose() async {
    _activeSession = null;
    await _tokenRefreshSubscription?.cancel();
    _client.close();
  }
}

class DeviceTokenApiException implements Exception {
  const DeviceTokenApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
