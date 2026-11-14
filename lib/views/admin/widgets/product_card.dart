import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final String store;
  final String stock;

  const ProductCard({
    super.key,
    required this.name,
    required this.store,
    required this.stock,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE8EDF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08172B4D),
            blurRadius: 13,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: const Color(0xffEAF5F0),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xff168A62),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xff243344),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  store,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xff75839A),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xffEAF0FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Stock $stock",
              style: const TextStyle(
                color: Color(0xff5875E8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
