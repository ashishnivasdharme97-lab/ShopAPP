import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/category_model.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class CategoryService {
  static Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(
        Uri.parse("https://shopapi-5amg.onrender.com/api/category"),
      );

      if (response.statusCode == 200) {
          print(response.body); // <-- hi line add kara

        final List data = jsonDecode(response.body);

        return data
            .map((e) => CategoryModel.fromJson(e))
            .toList();
      }

      return [];
    } catch (e) {
      print(e);
      return [];
    }
  }

  static Future<bool> addCategory({
  required String name,
  required XFile image,
}) async {
  try {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("https://shopapi-5amg.onrender.com/api/category"),
    );

    request.fields["Name"] = name;

    if (kIsWeb) {
      final bytes = await image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          "CategoryImage",
          bytes,
          filename: image.name,
        ),
      );
    } else {
      request.files.add(
        await http.MultipartFile.fromPath(
          "CategoryImage",
          image.path,
        ),
      );
    }

    final response = await request.send();

    return response.statusCode == 200 ||
        response.statusCode == 201;
  } catch (e) {
    print(e);
    return false;
  }
}
}