class SaleItemModel {
  final int productId;
  final double rate;
  final int quantity;
  final double amount;

  SaleItemModel({
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
  final double totalAmount;
  final double paidAmount;
  final double udhariAmount;
  final String paymentMode;
  final String? customerName;
  final List<SaleItemModel> items;

  CreateSaleModel({
    required this.totalAmount,
    required this.paidAmount,
    required this.udhariAmount,
    required this.paymentMode,
    required this.items,
    required this.customerName,
  });

  Map<String, dynamic> toJson() {
    return {
      "totalAmount": totalAmount,
      "paidAmount": paidAmount,
      "udhariAmount": udhariAmount,
      "paymentMode": paymentMode,
      "items": items.map((e) => e.toJson()).toList(),
      "customerName": customerName,
    };
  }
}