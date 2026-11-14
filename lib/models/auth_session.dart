enum AccountRole {
  user('User'),
  admin('Admin');

  const AccountRole(this.apiValue);

  final String apiValue;

  static AccountRole? fromApi(String? value) {
    for (final role in AccountRole.values) {
      if (role.apiValue.toLowerCase() == value?.toLowerCase()) return role;
    }
    return null;
  }
}

class AuthSession {
  const AuthSession({
    required this.token,
    required this.email,
    required this.role,
    this.shopName,
  });

  final String token;
  final String email;
  final AccountRole role;
  final String? shopName;
}
