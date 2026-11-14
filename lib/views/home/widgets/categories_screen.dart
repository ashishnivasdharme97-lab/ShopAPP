import 'package:flutter/material.dart';
import 'package:shop_app/models/category_model.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/data/default_categories.dart';
import 'package:shop_app/views/home/widgets/category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final List<CategoryModel> categories;
  final List<ProductModel> products;

  const CategoriesScreen({
    super.key,
    required this.categories,
    required this.products,
  });

  static const _ink = Color(0xff172B4D);
  static const _muted = Color(0xff75839A);
  static const _green = Color(0xff168A62);
  static const _canvas = Color(0xffF4F7FB);

  @override
  Widget build(BuildContext context) {
    final visibleCategories =
        categories.isEmpty ? defaultStoreCategories : categories;

    return Scaffold(
      backgroundColor: _canvas,
      appBar: AppBar(
        backgroundColor: _canvas,
        foregroundColor: _ink,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Categories',
          style: TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
              child: _buildIntro(),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 700
                      ? 4
                      : constraints.maxWidth >= 420
                          ? 3
                          : 2;
                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: visibleCategories.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: 13,
                      mainAxisSpacing: 13,
                      childAspectRatio: 0.83,
                    ),
                    itemBuilder: (context, index) {
                      return _CategoryCard(
                        category: visibleCategories[index],
                        index: index,
                        onTap: () {
                          final category = visibleCategories[index];
                          final categoryProducts = products
                              .where((product) =>
                                  product.categoryName == category.categoryName)
                              .toList();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CategoryProductsScreen(
                                title: category.categoryName,
                                products: categoryProducts,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shop by category',
                style: TextStyle(
                  color: _ink,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Browse ${categories.isEmpty ? defaultStoreCategories.length : categories.length} categories and find what you need.',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xffE7F4EE),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.grid_view_rounded,
            color: _green,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final int index;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.index,
    required this.onTap,
  });

  static const _green = Color(0xff168A62);
  static const _ink = Color(0xff172B4D);

  static const _colors = [
    Color(0xffE8F4EF),
    Color(0xffEEF0FF),
    Color(0xffFFF1E7),
    Color(0xffE9F4F8),
    Color(0xffF7EDF8),
    Color(0xffF5F2E8),
  ];

  @override
  Widget build(BuildContext context) {
    final imageUrl = category.categoryImage;
    final tint = _colors[index % _colors.length];

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        borderRadius: BorderRadius.circular(21),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: const Color(0xffE8EDF4)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x09172B4D),
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                        width: double.infinity,
                        color: tint,
                        child: imageUrl == null || imageUrl.isEmpty
                            ? _imagePlaceholder()
                            : imageUrl.startsWith('assets/')
                                ? Image.asset(
                                    imageUrl,
                                    fit: BoxFit.contain,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _imagePlaceholder(),
                                  )
                                : Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            _imagePlaceholder(),
                                  )),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.categoryName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: _green,
                        size: 16,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 3),
                  child: Text(
                    'Explore',
                    style: TextStyle(
                      color: Color(0xff8995A8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Center(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.category_rounded,
          color: _green,
          size: 25,
        ),
      ),
    );
  }
}
