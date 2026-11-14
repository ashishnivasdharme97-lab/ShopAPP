class UdharModel {
  const UdharModel({
    this.id,
    required this.userId,
    required this.customerName,
    required this.amount,
    required this.remainingAmount,
    required this.dueDate,
    this.notes,
    required this.isPaid,
    required this.paidAmount,
    this.createdAtUtc,
    this.updatedAtUtc,
  });

  final int? id;
  final int userId;
  final String customerName;
  final double amount;
  final double remainingAmount;
  final DateTime dueDate;
  final String? notes;
  final bool isPaid;
  final double paidAmount;
  final DateTime? createdAtUtc;
  final DateTime? updatedAtUtc;

  factory UdharModel.fromJson(Map<String, dynamic> json) {
    return UdharModel(
      id: _asInt(json['id']),
      userId: _asInt(json['userId']) ?? 0,
      customerName: json['customerName']?.toString() ?? '',
      amount: _asDouble(json['amount']),
      remainingAmount: _asDouble(json['remainingAmount']),
      dueDate: DateTime.parse(json['dueDate'].toString()),
      notes: json['notes']?.toString(),
      isPaid: json['isPaid'] == true,
      paidAmount: _asDouble(json['paidAmount']),
      createdAtUtc: _asDateTime(json['createdAtUtc']),
      updatedAtUtc: _asDateTime(json['updatedAtUtc']),
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'userId': userId,
        ...toUpdateJson(),
      };

  Map<String, dynamic> toUpdateJson() => {
        'customerName': customerName.trim(),
        'amount': amount,
        'remainingAmount': remainingAmount,
        'dueDate': dueDate.toUtc().toIso8601String(),
        'notes': notes?.trim().isEmpty == true ? null : notes?.trim(),
        'isPaid': isPaid,
        'paidAmount': paidAmount,
      };

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
