import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/models/product_model.dart';

class ProductService {
  static Future<bool> addProduct({
    required String name,
    required String description,
    required double price,
    required int quantity,
    required int categoryId,
    required XFile image,
  }) async {
    try {
      var request = http.MultipartRequest(
        "POST",
Uri.parse("https://shopapi-5amg.onrender.com/api/product")
            );      request.fields["ProductName"] = name;
      request.fields["Description"] = description;
      request.fields["Price"] = price.toString();
      request.fields["Quantity"] = quantity.toString();
      request.fields["CategoryId"] = categoryId.toString();

     if (kIsWeb) {
  final bytes = await image.readAsBytes();

  request.files.add(
    http.MultipartFile.fromBytes(
      "ProductImage",
      bytes,
      filename: image.name,
    ),
  );
} else {
  request.files.add(
    await http.MultipartFile.fromPath(
      "ProductImage",
      image.path,
    ),
  );
}

      final response = await request.send();

      final body = await response.stream.bytesToString();

      print("=================================");
      print("STATUS CODE : ${response.statusCode}");
      print("RESPONSE    : $body");
      print("=================================");

      return response.statusCode == 200 ||
          response.statusCode == 201;
    } catch (e) {
      print("ERROR : $e");
      return false;
    }
  }
static Future<List<ProductModel>> getProducts() async {
  try {
    final response = await http.get(
Uri.parse("https://shopapi-5amg.onrender.com/api/product")   );



print("STATUS CODE: ${response.statusCode}");
    print("RESPONSE: ${response.body}");
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((e) => ProductModel.fromJson(e))
          .toList();
    }

    return [];
  } catch (e) {
    print("GET ERROR : $e");
    return [];
  }
}




static Future<List<ProductModel>> getProductsByCategory(
    int categoryId) async {
  try {
    final response = await http.get(
      Uri.parse(
        "https://shopapi-5amg.onrender.com/api/product/category/$categoryId",
      ),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data
          .map((e) => ProductModel.fromJson(e))
          .toList();
    }

    return [];
  } catch (e) {
    print(e);
    return [];
  }
}}