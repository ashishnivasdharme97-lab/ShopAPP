import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/product_request_model.dart';

class ProductRequestService {
  static const String apiBaseUrl = "https://shopapi-5amg.onrender.com/api";
  static const String baseUrl = "$apiBaseUrl/ProductRequest";

  static Future<List<ProductRequestModel>> getAllRequests(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/requests"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((e) => ProductRequestModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<List<ProductRequestModel>> getPendingRequests() async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/admin/pending"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((e) => ProductRequestModel.fromJson(e)).toList();
      }

      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<bool> approveRequest(
    int id,
    String token,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/approve/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }

  static Future<bool> rejectRequest(
    int id,
    String token,
  ) async {
    final response = await http.put(
      Uri.parse("$baseUrl/reject/$id"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return response.statusCode == 200;
  }

  static Future<List<ProductRequestModel>> getMyRequests(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/my"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data.map((e) => ProductRequestModel.fromJson(e)).toList();
      }

      debugPrint('MY REQUESTS API RESPONSE: HTTP ${response.statusCode}');
      throw ProductRequestLoadException(
        'Could not load your requests (HTTP ${response.statusCode}).',
      );
    } catch (e) {
      debugPrint('MY REQUESTS API ERROR: $e');
      rethrow;
    }
  }

  static Future<List<ProductRequestModel>> getRequestHistory(
      String token) async {
    final response = await http.get(
      Uri.parse("$baseUrl/admin/history"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode != 200) {
      throw ProductRequestLoadException(
        'Could not load request history (HTTP ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const ProductRequestLoadException(
        'The request history API returned an unexpected response.',
      );
    }

    return decoded
        .map((item) =>
            ProductRequestModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<int> createRequest({
    required String productName,
    required String description,
    required int quantity,
  }) async {
    final http.Response response;
    try {
      debugPrint('REQUEST API: POST $baseUrl');
      response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "productName": productName,
              "description": description,
              "quantity": quantity,
            }),
          )
          .timeout(const Duration(seconds: 60));
    } on TimeoutException {
      debugPrint('REQUEST API FAILED: timed out after 60 seconds');
      throw const ProductRequestSubmissionException(
        'The request server did not respond in time. Please try again later.',
      );
    } on http.ClientException catch (error) {
      debugPrint('REQUEST API CLIENT ERROR: $error');
      throw const ProductRequestSubmissionException(
        'The browser could not reach the request API. Check that the backend is running and allows this app through CORS.',
      );
    } catch (error) {
      debugPrint('REQUEST API CONNECTION ERROR: $error');
      throw ProductRequestSubmissionException(
        'Could not connect to the request server: $error',
      );
    }

    debugPrint('REQUEST API RESPONSE: HTTP ${response.statusCode}');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      var detail = '';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          detail =
              (decoded['message'] ?? decoded['error'] ?? decoded['title'] ?? '')
                  .toString()
                  .trim();
        }
      } on FormatException {
        detail = '';
      }
      debugPrint(
        'REQUEST API FAILED: HTTP ${response.statusCode}'
        '${detail.isEmpty ? '' : ' - $detail'}',
      );

      throw ProductRequestSubmissionException(
        detail.isEmpty
            ? 'The server rejected the request (${response.statusCode}).'
            : detail,
      );
    }

    debugPrint('REQUEST API SUCCESS: HTTP ${response.statusCode}');
    return response.statusCode;
  }
}

class ProductRequestSubmissionException implements Exception {
  final String message;

  const ProductRequestSubmissionException(this.message);

  @override
  String toString() => message;
}

class ProductRequestLoadException implements Exception {
  final String message;

  const ProductRequestLoadException(this.message);

  @override
  String toString() => message;
}
