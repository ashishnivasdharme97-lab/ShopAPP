class ProductModel {
  final int id;
  final String productName;
  final String description;
  final double price;
  final int quantity;
  final String productImage;
  final String categoryName;

  ProductModel({
    required this.id,
    required this.productName,
    required this.description,
    required this.price,
    required this.quantity,
    required this.productImage,
    required this.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json["id"],
      productName: json["productName"],
      description: json["description"],
      price: (json["price"] as num).toDouble(),
      quantity: json["quantity"],
      productImage: json["productImage"],
      categoryName: json["categoryName"],
    );
  }
}