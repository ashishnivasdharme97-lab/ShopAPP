class ProductReportModel {
  final int productId;
  final String productName;
  final int totalQuantitySold;
  final double totalSaleAmount;
  final int currentStock;

  ProductReportModel({
    required this.productId,
    required this.productName,
    required this.totalQuantitySold,
    required this.totalSaleAmount,
    required this.currentStock,
  });

  factory ProductReportModel.fromJson(Map<String, dynamic> json) {
    return ProductReportModel(
      productId: json["productId"] ?? 0,
      productName: json["productName"] ?? "",
      totalQuantitySold: json["totalQuantitySold"] ?? 0,
      totalSaleAmount: (json["totalSaleAmount"] ?? 0).toDouble(),
      currentStock: json["currentStock"] ?? 0,
    );
  }
}