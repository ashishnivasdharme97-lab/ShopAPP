import 'package:flutter/material.dart';

class PopularProductsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const PopularProductsScreen({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xffF5F7FA),
        foregroundColor: const Color(0xff172B4D),
        elevation: 0,
        titleSpacing: 18,
        title: const Text(
          "Popular Products",
          style: TextStyle(
            color: Color(0xff172B4D),
            fontWeight: FontWeight.w800,
            fontSize: 19,
          ),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(18),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          mainAxisExtent: 158,
        ),
        itemBuilder: (context, index) {
          final item = products[index];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xffE9EDF2)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x080E1B2A),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // IMAGE
                  Container(
                    height: 45,
                    width: 45,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xffF1F6F4),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Image.asset(
                      item["image"],
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // NAME
                  Text(
                    item["name"],
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // PRICE
                  Text(
                    item["price"],
                    style: TextStyle(
                      color: item["color"],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
