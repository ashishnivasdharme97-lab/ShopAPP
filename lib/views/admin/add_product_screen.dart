import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/models/category_model.dart';
import 'package:shop_app/services/category_service.dart';
import 'package:shop_app/services/local_notification_service.dart';
import 'package:shop_app/services/product_service.dart';
import 'package:shop_app/views/admin/widgets/add_category_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  static const _canvas = Color(0xffF4F7FB);
  static const _ink = Color(0xff172B4D);
  static const _muted = Color(0xff75839A);
  static const _green = Color(0xff168A62);

  int categoryId = 1;
  XFile? selectedImage;
  final ImagePicker picker = ImagePicker();
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  List<CategoryModel> categories = [];
  String? category;

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      setState(() {
        selectedImage = pickedFile;
      });
    }
  }

  Future<void> loadCategories() async {
    final loadedCategories = await CategoryService.getCategories();
    if (!mounted) return;

    setState(() {
      categories = loadedCategories;
      if (categories.isNotEmpty) {
        category = categories.first.categoryName;
        categoryId = categories.first.id;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  @override
  void dispose() {
    productNameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitProduct() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select image first')),
      );
      return;
    }

    final success = await ProductService.addProduct(
      name: productNameController.text,
      description: descriptionController.text,
      price: double.tryParse(priceController.text) ?? 0,
      quantity: int.tryParse(quantityController.text) ?? 0,
      categoryId: categoryId,
      image: selectedImage!,
    );

    if (!mounted) return;
    if (success) {
      try {
        await LocalNotificationService.add(
          audience: 'user',
          title: 'New product added',
          message: '${productNameController.text.trim()} is now available.',
        );
      } catch (error) {
        debugPrint('PRODUCT NOTIFICATION SAVE ERROR: $error');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product Added Successfully')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add product')),
      );
    }
  }

  Future<void> _addCategory() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCategoryScreen()),
    );
    if (result == true) {
      await loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        foregroundColor: _ink,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Add product',
          style: TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntro(),
            const SizedBox(height: 20),
            _buildImagePicker(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(17),
              decoration: _cardDecoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _FormSectionTitle(
                    icon: Icons.description_outlined,
                    title: 'Product details',
                    subtitle: 'Add the basic information',
                  ),
                  const SizedBox(height: 20),
                  const _FieldLabel('Product name'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: productNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: _inputDecoration(
                      hint: 'e.g. Organic turmeric powder',
                      icon: Icons.shopping_bag_outlined,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Expanded(child: _FieldLabel('Category')),
                      TextButton.icon(
                        onPressed: _addCategory,
                        style: TextButton.styleFrom(
                          foregroundColor: _green,
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Add category',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xffE5EAF1)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: category,
                        hint: const Text(
                          'Select category',
                          style: TextStyle(color: _muted, fontSize: 14),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _muted,
                        ),
                        items: categories.map((item) {
                          return DropdownMenuItem<String>(
                            value: item.categoryName,
                            child: Text(item.categoryName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          final selected = categories.firstWhere(
                            (item) => item.categoryName == value,
                          );
                          setState(() {
                            category = selected.categoryName;
                            categoryId = selected.id;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Quantity'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              decoration: _inputDecoration(
                                hint: '0',
                                icon: Icons.inventory_2_outlined,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FieldLabel('Price'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              decoration: _inputDecoration(
                                hint: '0.00',
                                prefix: '₹ ',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const _FieldLabel('Description'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: _inputDecoration(
                      hint: 'Add product details or notes',
                      alignLabelWithHint: true,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _submitProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: _green.withValues(alpha: 0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'ADD PRODUCT',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create a product',
          style: TextStyle(
            color: _ink,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 5),
        Text(
          'Add it to your inventory with a few details.',
          style: TextStyle(color: _muted, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
      onTap: pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selectedImage == null
                ? const Color(0xffD5E5DD)
                : const Color(0xffE8EDF4),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08172B4D),
              blurRadius: 14,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: selectedImage == null
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Color(0xffEAF5F0),
                    child: Icon(
                      Icons.add_a_photo_outlined,
                      color: _green,
                      size: 23,
                    ),
                  ),
                  SizedBox(height: 11),
                  Text(
                    'Upload product image',
                    style: TextStyle(
                      color: _ink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap to choose from your gallery',
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    kIsWeb
                        ? Image.network(
                            selectedImage!.path,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(selectedImage!.path),
                            fit: BoxFit.cover,
                          ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.edit_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Change image',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    IconData? icon,
    String? prefix,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xffA0AABD), fontSize: 13),
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: const Color(0xff8A97AA), size: 19),
      prefixText: prefix,
      prefixStyle: const TextStyle(
        color: _ink,
        fontWeight: FontWeight.w600,
      ),
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: const Color(0xffF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffE5EAF1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _green, width: 1.4),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xffE8EDF4)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08172B4D),
          blurRadius: 16,
          offset: Offset(0, 6),
        ),
      ],
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FormSectionTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xffEAF5F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xff168A62), size: 19),
        ),
        const SizedBox(width: 11),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Color(0xff172B4D),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: Color(0xff75839A),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;

  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xff344563),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
