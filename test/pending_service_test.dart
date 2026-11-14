import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/services/pending_service.dart';

void main() {
  test('User sessions cannot request the Admin pending list', () async {
    const userSession = AuthSession(
      token: 'user-token',
      email: 'user@example.com',
      role: AccountRole.user,
    );

    await expectLater(
      PendingService.getPendingForAdmin(userSession),
      throwsA(isA<PendingApiException>()),
    );
  });

  test('Admin sessions cannot request the User pending list', () async {
    const adminSession = AuthSession(
      token: 'admin-token',
      email: 'admin@example.com',
      role: AccountRole.admin,
    );

    await expectLater(
      PendingService.getPendingForUser(adminSession),
      throwsA(isA<PendingApiException>()),
    );
  });
}
