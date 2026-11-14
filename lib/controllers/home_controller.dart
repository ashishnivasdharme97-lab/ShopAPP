import '../models/product_model.dart';

class HomeController {
  List<String> modules = [];
  List<String> categories = [];
  List<ProductModel> products = [];

  Future<void> loadData() async {
    modules = ["Sale", "Order", "Udhari"];
    categories = ["Grocery", "Snacks", "Drinks"];

    products = [
  ProductModel(
    id: 1,
    productName: "Rice",
    description: "Rice",
    price: 50.0,
    quantity: 10,
    productImage: "https://via.placeholder.com/150",
    categoryName: "Grocery",
  ),
  ProductModel(
    id: 2,
    productName: "Sugar",
    description: "Sugar",
    price: 40.0,
    quantity: 20,
    productImage: "https://via.placeholder.com/150",
    categoryName: "Grocery",
  ),
];
  }
}