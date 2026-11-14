class SalesSummaryModel {
  final double totalSales;
  final double collectedAmount;
  final double pendingAmount;
  final double cashCollection;
  final double upiCollection;
  final int totalBills;
  final int productsSold;

  SalesSummaryModel({
    required this.totalSales,
    required this.collectedAmount,
    required this.pendingAmount,
    required this.cashCollection,
    required this.upiCollection,
    required this.totalBills,
    required this.productsSold,
  });

  factory SalesSummaryModel.fromJson(Map<String, dynamic> json) {
    return SalesSummaryModel(
      totalSales: (json["totalSales"] ?? 0).toDouble(),
      collectedAmount: (json["collectedAmount"] ?? 0).toDouble(),
      pendingAmount: (json["pendingAmount"] ?? 0).toDouble(),
      cashCollection: (json["cashCollection"] ?? 0).toDouble(),
      upiCollection: (json["upiCollection"] ?? 0).toDouble(),
      totalBills: json["totalBills"] ?? 0,
      productsSold: json["productsSold"] ?? 0,
    );
  }
}