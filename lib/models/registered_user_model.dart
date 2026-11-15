class RegisteredUserModel {
  const RegisteredUserModel({
    required this.id,
    required this.name,
    required this.email,
    this.shopName,
  });

  final int id;
  final String name;
  final String email;
  final String? shopName;

  factory RegisteredUserModel.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id']);
    final name = json['name']?.toString().trim() ?? '';
    final email = json['email']?.toString().trim() ?? '';
    if (id == null || id <= 0 || name.isEmpty || email.isEmpty) {
      throw const FormatException(
        'The Users API returned an invalid registered user.',
      );
    }

    return RegisteredUserModel(
      id: id,
      name: name,
      email: email,
      shopName: json['shopName']?.toString(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
