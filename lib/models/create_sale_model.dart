import 'dart:math';

class SaleItemModel {
  final int productId;
  final double rate;
  final int quantity;
  final double amount;

  const SaleItemModel({
    required this.productId,
    required this.rate,
    required this.quantity,
    required this.amount,
  });

  Map<String, dynamic> toJson() {
    return {
      "productId": productId,
      "rate": rate,
      "quantity": quantity,
      "amount": amount,
    };
  }
}

class CreateSaleModel {
  final int userId;
  final String idempotencyKey;
  final double totalAmount;
  final double paidAmount;
  final double udhariAmount;
  final String paymentMode;
  final String customerName;
  final DateTime? dueDate;
  final List<SaleItemModel> items;

  CreateSaleModel({
    required this.userId,
    required this.idempotencyKey,
    required this.totalAmount,
    required this.paidAmount,
    required this.udhariAmount,
    required this.paymentMode,
    required this.items,
    required this.customerName,
    required this.dueDate,
  }) {
    if (userId <= 0) {
      throw ArgumentError.value(userId, 'userId', 'Must be a registered user.');
    }
    if (idempotencyKey.trim().isEmpty) {
      throw ArgumentError.value(
        idempotencyKey,
        'idempotencyKey',
        'Must not be empty.',
      );
    }
    if (!totalAmount.isFinite || totalAmount <= 0) {
      throw ArgumentError.value(
          totalAmount, 'totalAmount', 'Must be greater than 0.');
    }
    if (!paidAmount.isFinite || paidAmount < 0) {
      throw ArgumentError.value(
          paidAmount, 'paidAmount', 'Must not be negative.');
    }
    if (!udhariAmount.isFinite || udhariAmount < 0) {
      throw ArgumentError.value(
          udhariAmount, 'udhariAmount', 'Must not be negative.');
    }
    if (_toCents(paidAmount) + _toCents(udhariAmount) !=
        _toCents(totalAmount)) {
      throw ArgumentError(
          'Paid amount and Udhari must equal the total amount.');
    }
    if (udhariAmount > 0 && dueDate == null) {
      throw ArgumentError('A due date is required when Udhari is due.');
    }
    if (customerName.trim().isEmpty) {
      throw ArgumentError.value(
        customerName,
        'customerName',
        'Must not be empty.',
      );
    }
    if (items.isEmpty) {
      throw ArgumentError.value(
          items, 'items', 'At least one item is required.');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "idempotencyKey": idempotencyKey,
      "totalAmount": totalAmount,
      "paidAmount": paidAmount,
      "udhariAmount": udhariAmount,
      if (dueDate != null) "dueDate": _dateOnly(dueDate!),
      "paymentMode": paymentMode,
      "items": items.map((item) => item.toJson()).toList(),
      "customerName": customerName.trim(),
    };
  }

  static String newIdempotencyKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0'));
    final value = hex.join();
    return '${value.substring(0, 8)}-${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-${value.substring(16, 20)}-'
        '${value.substring(20)}';
  }

  static int _toCents(double value) => (value * 100).round();

  static String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
