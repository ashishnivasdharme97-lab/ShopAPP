class PendingModel {
  final String customerName;
  final double amount;
  final String reason;
  final DateTime createdAt;
  final String status;

  const PendingModel({
    required this.customerName,
    required this.amount,
    required this.reason,
    required this.createdAt,
    required this.status,
  });

  factory PendingModel.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '');

    return PendingModel(
      customerName: json['customerName']?.toString() ?? '',
      amount: _asDouble(json['amount']),
      reason: json['reason']?.toString() ?? '',
      createdAt: createdAt ?? DateTime.now(),
      status: json['status']?.toString() ?? 'Pending',
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
