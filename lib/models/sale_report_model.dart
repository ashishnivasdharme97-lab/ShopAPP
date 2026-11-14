class SaleReportModel {
  final String billNo;
  final double grandTotal;
  final double paidAmount;
  final double remainingAmount;
  final String paymentMode;
  final DateTime createdAt;

  SaleReportModel({
    required this.billNo,
    required this.grandTotal,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentMode,
    required this.createdAt,
  });

  factory SaleReportModel.fromJson(Map<String, dynamic> json) {
    return SaleReportModel(
      billNo: json["billNo"] ?? "",
      grandTotal: (json["grandTotal"] ?? 0).toDouble(),
      paidAmount: (json["paidAmount"] ?? 0).toDouble(),
      remainingAmount: (json["remainingAmount"] ?? 0).toDouble(),
      paymentMode: json["paymentMode"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}