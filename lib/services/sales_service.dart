import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/models/create_sale_model.dart';
import 'package:shop_app/models/dashboard_model.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/models/sale_response_model.dart';
import 'package:shop_app/services/api_config.dart';
import 'package:shop_app/services/product_service.dart';

class SalesService {
  SalesService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static String get baseUrl => '${ApiConfig.baseUrl}/Sales';

  Future<SaleResponseModel> createBill(
    CreateSaleModel sale,
    AuthSession session,
  ) async {
    if (session.role != AccountRole.admin) {
      throw const SalesApiException(
        'An Admin account is required to create a bill.',
      );
    }

    late final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${session.token}',
            },
            body: jsonEncode(sale.toJson()),
          )
          .timeout(const Duration(seconds: 30));
    } on http.ClientException catch (error) {
      throw SalesApiException('Network error while saving bill: $error');
    } on TimeoutException {
      throw const SalesApiException(
        'The bill request timed out. Retry to safely check the same bill.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw SalesApiException(
        _errorMessage(response.statusCode, response.body),
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const SalesApiException(
        'The Sales API returned an unexpected bill response.',
      );
    }

    try {
      return SaleResponseModel.fromJson(decoded);
    } on FormatException catch (error) {
      throw SalesApiException(error.message);
    }
  }

  void close() => _client.close();

  static Future<DashboardModel?> getDashboard() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/dashboard'));
      if (response.statusCode == 200) {
        return DashboardModel.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (error) {
      print(error);
      return null;
    }
  }

  static String _errorMessage(int statusCode, String body) {
    final detail = _responseDetail(body);
    return switch (statusCode) {
      400 => detail.isNotEmpty
          ? detail
          : 'Please check the bill details and try again.',
      401 => 'Your session has expired. Please sign in again.',
      403 => 'You do not have permission to create this bill.',
      404 => 'The Sales API route was not found on the server.',
      409 => detail.isNotEmpty
          ? 'Bill idempotency conflict: $detail'
          : 'Bill idempotency conflict. Verify the previous request; do not '
              'retry with a new key.',
      _ =>
        detail.isNotEmpty ? detail : 'Could not save bill (HTTP $statusCode).',
    };
  }

  static String _responseDetail(String body) {
    if (body.trim().isEmpty) return '';
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map<String, dynamic>) return '';
      for (final key in ['detail', 'title', 'message', 'error']) {
        final value = decoded[key];
        if (value is String && value.trim().isNotEmpty) return value.trim();
      }
      final errors = decoded['errors'];
      if (errors is Map) {
        return errors.values
            .expand((value) => value is List ? value : [value])
            .map((value) => value.toString())
            .where((value) => value.isNotEmpty)
            .join(' ');
      }
    } on FormatException {
      return '';
    }
    return '';
  }

  static Future<List<ProductModel>> getLowStockProducts() async {
    try {
      print("LOW STOCK API CALL START");

      final allProducts = await ProductService.getProducts();

      print("ALL PRODUCTS COUNT = ${allProducts.length}");

      const lowStockLimit = 5;
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
    } catch (error) {
      print("LOW STOCK ERROR = $error");
      return [];
    }
  }
}

class SalesApiException implements Exception {
  const SalesApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
