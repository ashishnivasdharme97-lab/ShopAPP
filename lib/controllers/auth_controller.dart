import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/services/auth_service.dart';
import 'package:shop_app/services/device_token_service.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    AuthService? service,
    DeviceTokenService? deviceTokenService,
  })  : _service = service ?? AuthService(),
        _deviceTokenService = deviceTokenService ?? DeviceTokenService();

  final AuthService _service;
  final DeviceTokenService _deviceTokenService;
  AuthSession? session;
  bool isRestoring = true;
  bool isBusy = false;

  Future<void> restoreSession() async {
    try {
      session = await _service.readSession();
      unawaited(_registerDeviceToken(session));
    } catch (_) {
      session = null;
    } finally {
      isRestoring = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    isBusy = true;
    notifyListeners();
    try {
      session = await _service.login(email: email, password: password);
      unawaited(_registerDeviceToken(session));
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> registerUser({
    required String email,
    required String password,
  }) async {
    await _runRegistration(
      () => _service.registerUser(email: email, password: password),
    );
  }

  Future<void> registerAdmin({
    required String shopName,
    required String email,
    required String password,
    required String setupKey,
  }) async {
    await _runRegistration(
      () => _service.registerAdmin(
        shopName: shopName,
        email: email,
        password: password,
        setupKey: setupKey,
      ),
    );
  }

  Future<void> _runRegistration(Future<void> Function() register) async {
    isBusy = true;
    notifyListeners();
    try {
      await register();
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    final currentSession = session;
    if (currentSession != null) {
      try {
        await _deviceTokenService.unregisterForSession(currentSession);
      } catch (error) {
        debugPrint('Could not unregister device token at logout: $error');
      }
    }
    await _service.logout();
    session = null;
    notifyListeners();
  }

  Future<void> _registerDeviceToken(AuthSession? currentSession) async {
    if (currentSession == null) return;
    try {
      await _deviceTokenService.registerForSession(currentSession);
    } catch (error) {
      debugPrint('Could not register device token: $error');
    }
  }

  @override
  void dispose() {
    _service.close();
    unawaited(_deviceTokenService.dispose());
    super.dispose();
  }
}
