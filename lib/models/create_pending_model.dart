class CreatePendingModel {
  final String customerName;
  final double amount;
  final String? reason;

  CreatePendingModel({
    required this.customerName,
    required this.amount,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      "customerName": customerName,
      "amount": amount,
      "reason": reason,
    };
  }
}