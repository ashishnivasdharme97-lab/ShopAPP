import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/dashboard_model.dart';
import 'package:shop_app/models/create_sale_model.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/services/api_config.dart';
import 'package:shop_app/services/product_service.dart';

class SalesService {
  static String get baseUrl => '${ApiConfig.baseUrl}/Sales';

  // Dashboard
  static Future<DashboardModel?> getDashboard() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/dashboard"));

      if (response.statusCode == 200) {
        return DashboardModel.fromJson(
          jsonDecode(response.body),
        );
      }

      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  // Create Sale
  static Future<bool> createSale(CreateSaleModel sale) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(sale.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      print(e);
      return false;
    }
  }

  static Future<List<ProductModel>> getLowStockProducts() async {
    try {
      print("LOW STOCK API CALL START");

      final allProducts = await ProductService.getProducts();

      print("ALL PRODUCTS COUNT = ${allProducts.length}");

      const int lowStockLimit = 5;

      final lowStockProducts = allProducts
          .where(
            (product) =>
                product.quantity >= 0 && product.quantity <= lowStockLimit,
          )
          .toList();

      print("LOW STOCK COUNT = ${lowStockProducts.length}");

      for (final product in lowStockProducts) {
        print(
          "LOW STOCK PRODUCT: "
          "${product.productName} | QTY: ${product.quantity}",
        );
      }

      return lowStockProducts;
    } catch (e) {
      print("LOW STOCK ERROR = $e");
      return [];
    }
  }
}
