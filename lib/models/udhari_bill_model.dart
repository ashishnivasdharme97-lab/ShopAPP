class UdhariBillModel {
  const UdhariBillModel({
    required this.id,
    required this.userId,
    required this.billId,
    required this.billReference,
    required this.customerName,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.dueDate,
    required this.createdAt,
  });

  final int id;
  final int userId;
  final String billId;
  final String billReference;
  final String customerName;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime? dueDate;
  final DateTime? createdAt;

  factory UdhariBillModel.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id'], 'id');
    final userId = _asInt(json['userId'], 'userId');
    final customerName = json['customerName']?.toString().trim() ?? '';
    if (customerName.isEmpty) {
      throw const FormatException('Udhari entry has no customer name.');
    }

    return UdhariBillModel(
      id: id,
      userId: userId,
      billId: json['billId']?.toString() ?? '',
      billReference: json['billReference']?.toString() ?? '',
      customerName: customerName,
      totalAmount: _asDouble(json['totalAmount'], 'totalAmount'),
      paidAmount: _asDouble(json['paidAmount'], 'paidAmount'),
      remainingAmount: _asDouble(json['remainingAmount'], 'remainingAmount'),
      dueDate: _asDateTime(json['dueDate'], 'dueDate', optional: true),
      createdAt: _asDateTime(json['createdAt'], 'createdAt'),
    );
  }

  static int _asInt(dynamic value, String field) {
    if (value is int) return value;
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      throw FormatException('Udhari entry has invalid $field.');
    }
    return parsed;
  }

  static double _asDouble(dynamic value, String field) {
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed == null || !parsed.isFinite) {
      throw FormatException('Udhari entry has invalid $field.');
    }
    return parsed;
  }

  static DateTime? _asDateTime(
    dynamic value,
    String field, {
    bool optional = false,
  }) {
    if (value == null && optional) return null;
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) {
      throw FormatException('Udhari entry has invalid $field.');
    }
    return parsed;
  }
}
