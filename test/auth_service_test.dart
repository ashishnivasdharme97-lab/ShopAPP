import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/services/auth_service.dart';

void main() {
  test('login stores the token and parses the account role', () async {
    final store = _MemorySessionStore();
    final client = MockClient((request) async {
      expect(request.url.path, '/api/Auth/login');
      expect(jsonDecode(request.body), {
        'email': 'admin@example.com',
        'password': 'secret123',
      });
      return http.Response(
        jsonEncode({
          'token': 'jwt-value',
          'user': {
            'email': 'admin@example.com',
            'role': 'Admin',
            'shopName': 'Green Market',
          },
        }),
        200,
      );
    });
    final service = AuthService(
      client: client,
      sessionStore: store,
      baseUrl: 'http://localhost:5022/api',
    );

    final session = await service.login(
      email: ' admin@example.com ',
      password: 'secret123',
    );

    expect(session.role, AccountRole.admin);
    expect(session.shopName, 'Green Market');
    expect(store.session?.token, 'jwt-value');
    service.close();
  });

  test('admin registration sends setup key only in its request header',
      () async {
    final store = _MemorySessionStore();
    final client = MockClient((request) async {
      expect(request.url.path, '/api/Auth/register/admin');
      expect(request.headers['X-Admin-Registration-Key'], 'one-time-key');
      expect(request.body, isNot(contains('one-time-key')));
      expect(jsonDecode(request.body), {
        'shopName': 'Green Market',
        'email': 'admin@example.com',
        'password': 'secret123',
      });
      return http.Response('', 201);
    });
    final service = AuthService(
      client: client,
      sessionStore: store,
      baseUrl: 'http://localhost:5022/api',
    );

    await service.registerAdmin(
      shopName: ' Green Market ',
      email: 'admin@example.com',
      password: 'secret123',
      setupKey: 'one-time-key',
    );

    expect(store.session, isNull);
    service.close();
  });

  test('maps login credential errors', () async {
    final service = AuthService(
      client: MockClient((_) async => http.Response('', 401)),
      sessionStore: _MemorySessionStore(),
      baseUrl: 'http://localhost:5022/api',
    );

    await expectLater(
      service.login(email: 'a@example.com', password: 'secret123'),
      throwsA(
        isA<AuthApiException>().having(
          (error) => error.message,
          'message',
          'Email or password is incorrect.',
        ),
      ),
    );
    service.close();
  });

  test('maps registration validation and admin setup errors', () async {
    final scenarios = <({int status, String body, String message})>[
      (
        status: 400,
        body: jsonEncode({
          'errors': {
            'Email': ['Invalid email address.']
          }
        }),
        message: 'Please check the submitted fields. Invalid email address.',
      ),
      (
        status: 401,
        body: '',
        message: 'The admin setup key is invalid.',
      ),
      (
        status: 409,
        body: '',
        message: 'This account or shop admin is already registered.',
      ),
      (
        status: 503,
        body: '',
        message: 'Admin setup is not configured on the server.',
      ),
    ];

    for (final scenario in scenarios) {
      final service = AuthService(
        client: MockClient(
          (_) async => http.Response(scenario.body, scenario.status),
        ),
        sessionStore: _MemorySessionStore(),
        baseUrl: 'http://localhost:5022/api',
      );

      await expectLater(
        service.registerAdmin(
          shopName: 'Shop',
          email: 'a@example.com',
          password: 'secret123',
          setupKey: 'key',
        ),
        throwsA(
          isA<AuthApiException>().having(
            (error) => error.message,
            'message',
            scenario.message,
          ),
        ),
      );
      service.close();
    }
  });

  test('logout clears the stored session', () async {
    final store = _MemorySessionStore()
      ..session = const AuthSession(
        token: 'jwt-value',
        email: 'user@example.com',
        role: AccountRole.user,
      );
    final service = AuthService(
      client: MockClient((_) async => http.Response('', 200)),
      sessionStore: store,
      baseUrl: 'http://localhost:5022/api',
    );

    await service.logout();

    expect(store.session, isNull);
    service.close();
  });
}

class _MemorySessionStore implements AuthSessionStore {
  AuthSession? session;

  @override
  Future<void> clear() async => session = null;

  @override
  Future<AuthSession?> read() async => session;

  @override
  Future<void> save(AuthSession value) async => session = value;
}
