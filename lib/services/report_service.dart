import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_report_model.dart';
import '../models/sale_report_model.dart';
import '../models/sales_summary_model.dart';

class ReportService {
  // तुमचा API URL येथे टाका
  static const String baseUrl =      "https://shopapi-5amg.onrender.com/api/Sales";
  // उदाहरण:
  // static const String baseUrl = "http://10.0.2.2:5000/api/Sales";
  // static const String baseUrl = "http://localhost:5000/api/Sales";

  /// ============================
  /// Master Summary Report
  /// GET : /api/Sales/master-report?type=daily
  /// ============================
  static Future<SalesSummaryModel?> getSummary(String period) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/master-report?type=$period"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return SalesSummaryModel.fromJson(
          jsonDecode(response.body),
        );
      }

      print("Summary Error : ${response.body}");
      return null;
    } catch (e) {
      print("Summary Exception : $e");
      return null;
    }
  }

  /// ============================
  /// Product Report
  /// GET : /api/Sales/product-report?type=daily
  /// ============================
  static Future<List<ProductReportModel>> getProductReport(
      String period) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/product-report?type=$period"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data
            .map((e) => ProductReportModel.fromJson(e))
            .toList();
      }

      print("Product Report Error : ${response.body}");
      return [];
    } catch (e) {
      print("Product Report Exception : $e");
      return [];
    }
  }

  /// ============================
  /// Bill Wise Report
  /// GET : /api/Sales/report?type=daily
  /// ============================
  static Future<List<SaleReportModel>> getBillReport(
      String period) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/report?type=$period"),
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data
            .map((e) => SaleReportModel.fromJson(e))
            .toList();
      }

      print("Bill Report Error : ${response.body}");
      return [];
    } catch (e) {
      print("Bill Report Exception : $e");
      return [];
    }
  }
}