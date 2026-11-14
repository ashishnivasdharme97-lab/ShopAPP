import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/controllers/auth_controller.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/root_screen.dart';
import 'package:shop_app/views/auth/auth_screen.dart';
import 'package:shop_app/views/admin/admin_layout.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    if (auth.isRestoring) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final session = auth.session;
    if (session == null) return const AuthScreen();

    return RoleBasedHome(
      session: session,
      adminBuilder: (_) => AdminLayout(
        session: session,
        onLogout: auth.logout,
      ),
      userBuilder: (_) => RootScreen(onLogout: auth.logout),
    );
  }
}

class RoleBasedHome extends StatelessWidget {
  const RoleBasedHome({
    super.key,
    required this.session,
    required this.adminBuilder,
    required this.userBuilder,
  });

  final AuthSession session;
  final WidgetBuilder adminBuilder;
  final WidgetBuilder userBuilder;

  @override
  Widget build(BuildContext context) {
    return session.role == AccountRole.admin
        ? adminBuilder(context)
        : userBuilder(context);
  }
}
