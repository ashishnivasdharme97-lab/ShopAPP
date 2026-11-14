import 'package:flutter_test/flutter_test.dart';
import 'package:shop_app/main.dart';
import 'package:shop_app/controllers/auth_controller.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/services/auth_service.dart';

void main() {
  testWidgets('app loads the authentication screen', (tester) async {
    await tester.pumpWidget(
      MyApp(
        authController: AuthController(
          service: AuthService(sessionStore: _MemorySessionStore()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kirana Store'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Admin setup'), findsOneWidget);
  });
}

class _MemorySessionStore implements AuthSessionStore {
  @override
  Future<void> clear() async {}

  @override
  Future<AuthSession?> read() async => null;

  @override
  Future<void> save(AuthSession session) async {}
}
