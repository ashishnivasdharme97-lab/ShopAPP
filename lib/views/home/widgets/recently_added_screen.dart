import 'package:flutter/material.dart';
import 'package:shop_app/models/product_model.dart';
import 'product_card.dart';

class RecentlyAddedScreen extends StatefulWidget {
  final List<ProductModel> products;

  const RecentlyAddedScreen({
    super.key,
    required this.products,
  });

  @override
  State<RecentlyAddedScreen> createState() => _RecentlyAddedScreenState();
}

class _RecentlyAddedScreenState extends State<RecentlyAddedScreen> {
  late List<ProductModel> filteredProducts;

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredProducts = widget.products;
  }

  void searchProducts(String value) {
    setState(() {
      filteredProducts = widget.products.where((product) {
        return product.productName
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            product.description.toLowerCase().contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffF5F7FA),
        foregroundColor: const Color(0xff172B4D),
        titleSpacing: 18,
        title: const Text(
          "Recently Added",
          style: TextStyle(
            color: Color(0xff172B4D),
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 15),
            child: Icon(
              Icons.shopping_cart_outlined,
              color: Color(0xff344054),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              controller: searchController,
              onChanged: searchProducts,
              decoration: InputDecoration(
                hintText: "Search recently added...",
                hintStyle: const TextStyle(color: Color(0xff98A2B3)),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: Color(0xff168A62)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xffE9EDF2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xffE9EDF2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xff168A62)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${filteredProducts.length} Products",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff172B4D),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffE9F5F0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.filter_alt_outlined,
                        color: Color(0xff168A62),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Filter",
                        style: TextStyle(
                          color: Color(0xff168A62),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: filteredProducts.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            color: Color(0xff168A62),
                            size: 42,
                          ),
                          SizedBox(height: 12),
                          Text(
                            "No products found",
                            style: TextStyle(
                              color: Color(0xff243344),
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "Try searching with a different name.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xff8995A8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    itemCount: filteredProducts.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: .60,
                    ),
                    itemBuilder: (context, index) {
                      return ProductCard(
                        product: filteredProducts[index],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
