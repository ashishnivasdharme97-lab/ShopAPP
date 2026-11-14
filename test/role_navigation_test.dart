import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/role_selection_screen.dart';

void main() {
  testWidgets('Admin session opens only the admin area', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RoleBasedHome(
          session: const AuthSession(
            token: 'admin-token',
            email: 'admin@example.com',
            role: AccountRole.admin,
          ),
          adminBuilder: (_) => const Text('admin-area'),
          userBuilder: (_) => const Text('user-area'),
        ),
      ),
    );

    expect(find.text('admin-area'), findsOneWidget);
    expect(find.text('user-area'), findsNothing);
  });

  testWidgets('User session opens only the user area', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: RoleBasedHome(
          session: const AuthSession(
            token: 'user-token',
            email: 'user@example.com',
            role: AccountRole.user,
          ),
          adminBuilder: (_) => const Text('admin-area'),
          userBuilder: (_) => const Text('user-area'),
        ),
      ),
    );

    expect(find.text('user-area'), findsOneWidget);
    expect(find.text('admin-area'), findsNothing);
  });
}
