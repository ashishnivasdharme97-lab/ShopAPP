class CategoryModel {
  final int id;
  final String categoryName;
  final String? categoryImage;

  const CategoryModel({
    required this.id,
    required this.categoryName,
    this.categoryImage,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json["id"],
      categoryName: json["categoryName"],
      categoryImage: json["categoryImage"],
    );
  }
}