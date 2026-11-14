class ProductRequestModel {
  final int id;
  final String productName;
  final String description;
  final String status;
  final int userId;
  final DateTime createdAt;
  final int quantity;
  final String userName;

  ProductRequestModel({
    required this.id,
    required this.productName,
    required this.description,
    required this.status,
    required this.userId,
    required this.createdAt,
    required this.quantity,
    required this.userName,
  });

  factory ProductRequestModel.fromJson(Map<String, dynamic> json) {
    int readInt(String key, {int fallback = 0}) {
      final value = json[key];
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? fallback;
    }

    final rawCreatedAt = json["createdAt"]?.toString();
    final createdAt = DateTime.tryParse(rawCreatedAt ?? '');

    return ProductRequestModel(
      id: readInt("id"),
      productName: json["productName"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      status: json["status"]?.toString() ?? "Pending",
      userId: readInt("userId"),
      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      quantity: readInt("quantity"),
      userName: json["user"]?["name"] ?? "",
    );
  }
}
