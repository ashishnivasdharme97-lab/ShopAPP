class SaleResponseModel {
  const SaleResponseModel({
    required this.saleId,
    required this.billNo,
    required this.userId,
    required this.totalAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.dueDate,
  });

  final String saleId;
  final String billNo;
  final int userId;
  final double totalAmount;
  final double paidAmount;
  final double remainingAmount;
  final DateTime? dueDate;

  factory SaleResponseModel.fromJson(Map<String, dynamic> json) {
    final saleId = json['saleId']?.toString() ?? '';
    final billNo = json['billNo']?.toString() ?? '';
    final userId = _asInt(json['userId']);
    if (saleId.isEmpty || billNo.isEmpty || userId == null) {
      throw const FormatException(
          'The Sales API response is missing bill data.');
    }

    return SaleResponseModel(
      saleId: saleId,
      billNo: billNo,
      userId: userId,
      totalAmount: _asDouble(json['totalAmount'], 'totalAmount'),
      paidAmount: _asDouble(json['paidAmount'], 'paidAmount'),
      remainingAmount: _asDouble(json['remainingAmount'], 'remainingAmount'),
      dueDate: _asDateTime(json['dueDate']),
    );
  }

  static int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  static double _asDouble(dynamic value, String field) {
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value?.toString() ?? '');
    if (parsed == null || !parsed.isFinite) {
      throw FormatException('The Sales API response has invalid $field.');
    }
    return parsed;
  }

  static DateTime? _asDateTime(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) {
      throw const FormatException(
        'The Sales API response has an invalid dueDate.',
      );
    }
    return parsed;
  }
}
