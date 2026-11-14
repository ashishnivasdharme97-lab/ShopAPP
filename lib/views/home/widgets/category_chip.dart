import 'package:flutter/material.dart';

class CategoryChip extends StatelessWidget {
  final String name;

  const CategoryChip({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xffE9F5F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffD8ECE3)),
      ),
      child: Text(
        name,
        style: const TextStyle(
          color: Color(0xff168A62),
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
