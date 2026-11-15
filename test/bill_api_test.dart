import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/models/create_sale_model.dart';
import 'package:shop_app/services/notification_service.dart';
import 'package:shop_app/services/registered_user_service.dart';
import 'package:shop_app/services/sales_service.dart';

void main() {
  const adminSession = AuthSession(
    token: 'admin-jwt',
    email: 'admin@example.com',
    role: AccountRole.admin,
  );
  const userSession = AuthSession(
    token: 'user-jwt',
    email: 'user@example.com',
    role: AccountRole.user,
  );
  const saleItem = SaleItemModel(
    productId: 7,
    rate: 120,
    quantity: 10,
    amount: 1200,
  );

  test('zero Udhari omits due date from the bill payload', () {
    final sale = _sale(
      paidAmount: 1200,
      udhariAmount: 0,
      dueDate: null,
    );

    expect(sale.toJson(), {
      'userId': 42,
      'idempotencyKey': 'same-key',
      'totalAmount': 1200,
      'paidAmount': 1200,
      'udhariAmount': 0,
      'paymentMode': 'Cash',
      'items': [saleItem.toJson()],
      'customerName': 'Customer Name',
    });
  });

  test('positive Udhari requires a due date and sends date-only format', () {
    expect(
      () => _sale(paidAmount: 700, udhariAmount: 500, dueDate: null),
      throwsArgumentError,
    );

    final sale = _sale(
      paidAmount: 700,
      udhariAmount: 500,
      dueDate: DateTime(2026, 11, 30),
    );
    expect(sale.toJson()['dueDate'], '2026-11-30');
  });

  test('bill uses selected registered user id and validates totals', () {
    final sale = _sale(
      paidAmount: 700,
      udhariAmount: 500,
      dueDate: DateTime(2026, 11, 30),
    );

    expect(sale.toJson()['userId'], 42);
    expect(sale.toJson()['totalAmount'], 1200);
    expect(sale.toJson()['paidAmount'], 700);
    expect(sale.toJson()['udhariAmount'], 500);
    expect(
      () => CreateSaleModel(
        userId: 42,
        idempotencyKey: 'same-key',
        totalAmount: 1200,
        paidAmount: 700,
        udhariAmount: 400,
        dueDate: DateTime(2026, 11, 30),
        paymentMode: 'Cash',
        customerName: 'Customer Name',
        items: const [saleItem],
      ),
      throwsArgumentError,
    );
  });

  test('bill retries reuse the exact key and payload with admin JWT', () async {
    final requestBodies = <String>[];
    var requestCount = 0;
    final service = SalesService(
      client: MockClient((request) async {
        requestCount++;
        expect(request.url.path, '/api/Sales');
        expect(request.headers['authorization'], 'Bearer admin-jwt');
        requestBodies.add(request.body);
        return http.Response(
          jsonEncode({
            'saleId': 'sale-1',
            'billNo': 'B-1',
            'userId': 42,
            'totalAmount': 1200,
            'paidAmount': 700,
            'remainingAmount': 500,
            'dueDate': '2026-11-30',
          }),
          requestCount == 1 ? 201 : 200,
        );
      }),
    );
    final sale = _sale(
      paidAmount: 700,
      udhariAmount: 500,
      dueDate: DateTime(2026, 11, 30),
    );

    final first = await service.createBill(sale, adminSession);
    final retry = await service.createBill(sale, adminSession);

    expect(first.billNo, 'B-1');
    expect(retry.saleId, first.saleId);
    expect(requestCount, 2);
    expect(requestBodies[1], requestBodies[0]);
    expect(
      (jsonDecode(requestBodies[1]) as Map<String, dynamic>)['idempotencyKey'],
      'same-key',
    );
    service.close();
  });

  test('registered user picker loads ids from GET /api/users', () async {
    final service = RegisteredUserService(
      client: MockClient((request) async {
        expect(request.url.path, '/api/users');
        expect(request.headers['authorization'], 'Bearer admin-jwt');
        return http.Response(
          jsonEncode([
            {
              'id': 42,
              'name': 'Customer Name',
              'email': 'customer@example.com',
              'shopName': null,
            }
          ]),
          200,
        );
      }),
    );

    final users = await service.getUsers(adminSession);
    expect(users.single.id, 42);
    expect(users.single.name, 'Customer Name');
    service.close();
  });

  test('personal notifications use GET /api/Notification/my', () async {
    final service = NotificationService(
      client: MockClient((request) async {
        expect(request.url.path, '/api/Notification/my');
        expect(request.headers['authorization'], 'Bearer user-jwt');
        return http.Response(
          jsonEncode([
            {
              'id': 5,
              'title': 'Udhari added',
              'body': 'A bill balance is due.',
              'createdAt': '2026-11-15T10:00:00Z',
            }
          ]),
          200,
        );
      }),
    );

    final notifications = await service.getMyNotifications(userSession);

    expect(notifications.single.title, 'Udhari added');
    expect(notifications.single.message, 'A bill balance is due.');
    service.close();
  });

  test('Sales API maps validation, authorization, and idempotency errors',
      () async {
    final errors = <({int statusCode, String? body, String message})>[
      (
        statusCode: 400,
        body: jsonEncode({'title': 'Invalid total amount.'}),
        message: 'Invalid total amount.',
      ),
      (
        statusCode: 401,
        body: '',
        message: 'Your session has expired. Please sign in again.',
      ),
      (
        statusCode: 403,
        body: '',
        message: 'You do not have permission to create this bill.',
      ),
      (
        statusCode: 409,
        body: '',
        message: 'Bill idempotency conflict. Verify the previous request; do '
            'not retry with a new key.',
      ),
    ];

    for (final scenario in errors) {
      final service = SalesService(
        client: MockClient(
          (_) async => http.Response(scenario.body ?? '', scenario.statusCode),
        ),
      );
      await expectLater(
        service.createBill(
          _sale(
            paidAmount: 1200,
            udhariAmount: 0,
            dueDate: null,
          ),
          adminSession,
        ),
        throwsA(
          isA<SalesApiException>().having(
            (error) => error.message,
            'message',
            scenario.message,
          ),
        ),
      );
      service.close();
    }
  });
}

CreateSaleModel _sale({
  required double paidAmount,
  required double udhariAmount,
  required DateTime? dueDate,
}) {
  return CreateSaleModel(
    userId: 42,
    idempotencyKey: 'same-key',
    totalAmount: 1200,
    paidAmount: paidAmount,
    udhariAmount: udhariAmount,
    dueDate: dueDate,
    paymentMode: 'Cash',
    customerName: 'Customer Name',
    items: const [
      SaleItemModel(
        productId: 7,
        rate: 120,
        quantity: 10,
        amount: 1200,
      ),
    ],
  );
}
