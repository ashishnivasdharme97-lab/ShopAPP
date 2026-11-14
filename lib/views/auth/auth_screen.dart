import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/controllers/auth_controller.dart';
import 'package:shop_app/services/auth_service.dart';

enum _AuthMode { login, userRegistration, adminSetup }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static const _ink = Color(0xff172B4D);
  static const _muted = Color(0xff75839A);
  static const _green = Color(0xff168A62);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _shopNameController = TextEditingController();
  final _setupKeyController = TextEditingController();
  _AuthMode _mode = _AuthMode.login;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _shopNameController.dispose();
    _setupKeyController.dispose();
    super.dispose();
  }

  Future<void> _submit(AuthController controller) async {
    if (!_formKey.currentState!.validate()) {
      if (_mode == _AuthMode.adminSetup) _setupKeyController.clear();
      return;
    }
    FocusScope.of(context).unfocus();
    final isAdminSetup = _mode == _AuthMode.adminSetup;

    try {
      if (_mode == _AuthMode.login) {
        await controller.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else if (_mode == _AuthMode.userRegistration) {
        await controller.registerUser(
          email: _emailController.text,
          password: _passwordController.text,
        );
        _showMessage('Account created. Sign in to continue.');
        setState(() => _mode = _AuthMode.login);
      } else {
        await controller.registerAdmin(
          shopName: _shopNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          setupKey: _setupKeyController.text,
        );
        _showMessage('Shop admin created. Sign in to continue.');
        setState(() => _mode = _AuthMode.login);
      }
    } on AuthApiException catch (error) {
      _showMessage(error.message);
    } catch (_) {
      _showMessage(
          'Could not reach the server. Check your connection and API URL.');
    } finally {
      if (isAdminSetup) _setupKeyController.clear();
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: const Color(0xffE9F5F0),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      color: _green,
                      size: 29,
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Kirana Store',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    _mode == _AuthMode.adminSetup
                        ? 'Set up the shop administrator'
                        : _mode == _AuthMode.userRegistration
                            ? 'Create your customer account'
                            : 'Sign in to continue',
                    style: const TextStyle(color: _muted, fontSize: 14),
                  ),
                  const SizedBox(height: 22),
                  SegmentedButton<_AuthMode>(
                    segments: const [
                      ButtonSegment(
                        value: _AuthMode.login,
                        label: Text('Login'),
                      ),
                      ButtonSegment(
                        value: _AuthMode.userRegistration,
                        label: Text('User'),
                      ),
                      ButtonSegment(
                        value: _AuthMode.adminSetup,
                        label: Text('Admin setup'),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: controller.isBusy
                        ? null
                        : (selection) {
                            _setupKeyController.clear();
                            setState(() => _mode = selection.first);
                          },
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xffE8EDF4)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_mode == _AuthMode.adminSetup) ...[
                            _textField(
                              controller: _shopNameController,
                              label: 'Shop name',
                              icon: Icons.store_outlined,
                              validator: (value) =>
                                  value == null || value.trim().isEmpty
                                      ? 'Enter the shop name'
                                      : null,
                            ),
                            const SizedBox(height: 14),
                          ],
                          _textField(
                            controller: _emailController,
                            label: 'Email',
                            icon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ),
                          const SizedBox(height: 14),
                          _textField(
                            controller: _passwordController,
                            label: 'Password',
                            icon: Icons.lock_outline_rounded,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          if (_mode == _AuthMode.adminSetup) ...[
                            const SizedBox(height: 14),
                            _textField(
                              controller: _setupKeyController,
                              label: 'One-time admin setup key',
                              icon: Icons.key_outlined,
                              obscureText: true,
                              validator: (value) =>
                                  value == null || value.isEmpty
                                      ? 'Enter the setup key'
                                      : null,
                            ),
                          ],
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: controller.isBusy
                                ? null
                                : () => _submit(controller),
                            style: FilledButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isBusy
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _mode == _AuthMode.login
                                        ? 'Sign in'
                                        : _mode == _AuthMode.userRegistration
                                            ? 'Create account'
                                            : 'Register shop admin',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions: !obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xffF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffE1E7EF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xffE1E7EF)),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your email';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }
}
