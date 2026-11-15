import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/controllers/auth_controller.dart';
import 'package:shop_app/controllers/udhari_controller.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/services/udhar_service.dart';
import 'package:shop_app/views/home/widgets/udhari_screen.dart';

void main() {
  const userSession = AuthSession(
    token: 'user-jwt',
    email: 'user@example.com',
    role: AccountRole.user,
  );

  test('Udhari list loads only from authenticated /api/Udhari/my response',
      () async {
    final service = UdharService(
      baseUrl: 'http://localhost/api',
      client: MockClient((request) async {
        expect(request.url.path, '/api/Udhari/my');
        expect(request.headers['authorization'], 'Bearer user-jwt');
        return http.Response(
          jsonEncode([
            {
              'id': 1,
              'userId': 42,
              'billId': 300,
              'billReference': 'B-300',
              'customerName': 'Shop customer',
              'totalAmount': 1200,
              'paidAmount': 700,
              'remainingAmount': 500,
              'dueDate': '2026-11-30',
              'createdAt': '2026-11-15T10:00:00Z',
            }
          ]),
          200,
        );
      }),
    );
    final entries = await service.getMyEntries(userSession);

    expect(entries, hasLength(1));
    expect(entries.single.userId, 42);
    expect(entries.single.billReference, 'B-300');
    expect(entries.single.remainingAmount, 500);
    service.close();
  });

  testWidgets('Udhari screen shows loading then bill details', (tester) async {
    final responseCompleter = Completer<http.Response>();
    final controller = _makeController(
      MockClient((_) => responseCompleter.future),
    );
    final authController = _makeAuthController(userSession);

    await tester.pumpWidget(
      _screen(authController, controller),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    responseCompleter.complete(
      http.Response(
        jsonEncode([
          {
            'id': 1,
            'userId': 42,
            'billId': 300,
            'billReference': 'B-300',
            'customerName': 'Customer Name',
            'totalAmount': 1200,
            'paidAmount': 700,
            'remainingAmount': 500,
            'dueDate': '2026-11-30',
            'createdAt': '2026-11-15T10:00:00Z',
          }
        ]),
        200,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bill B-300'), findsOneWidget);
    expect(find.text('Customer Name'), findsOneWidget);
    expect(find.text('₹1200.00'), findsOneWidget);
    expect(find.text('₹700.00'), findsOneWidget);
    expect(find.text('₹500.00'), findsOneWidget);
    expect(find.text('Due: 30/11/2026'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    authController.dispose();
  });

  testWidgets('Udhari screen shows empty state for an empty API response',
      (tester) async {
    final controller = _makeController(
      MockClient((_) async => http.Response('[]', 200)),
    );
    final authController = _makeAuthController(userSession);

    await tester.pumpWidget(_screen(authController, controller));
    await tester.pumpAndSettle();

    expect(find.text('No transactions yet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    authController.dispose();
  });

  testWidgets('Udhari screen displays API errors without fake entries',
      (tester) async {
    final controller = _makeController(
      MockClient((_) async => http.Response('missing', 404)),
    );
    final authController = _makeAuthController(userSession);

    await tester.pumpWidget(_screen(authController, controller));
    await tester.pumpAndSettle();

    expect(find.textContaining('HTTP 404'), findsOneWidget);
    expect(find.text('Bill'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    authController.dispose();
  });
}

UdhariController _makeController(http.Client client) => UdhariController(
      service: UdharService(
        baseUrl: 'http://localhost/api',
        client: client,
      ),
    );

AuthController _makeAuthController(AuthSession session) {
  final controller = AuthController();
  controller.session = session;
  return controller;
}

Widget _screen(
  AuthController authController,
  UdhariController udhariController,
) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<AuthController>.value(value: authController),
      ChangeNotifierProvider<UdhariController>.value(value: udhariController),
    ],
    child: const MaterialApp(home: UdhariScreen()),
  );
}
