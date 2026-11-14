import 'package:flutter/material.dart';

class RequestCard extends StatelessWidget {
  final String name;
  final String product;
  final String status;

  const RequestCard({
    super.key,
    required this.name,
    required this.product,
    required this.status,
  });

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case "pending":
        return const Color(0xffD98219);
      case "approved":
        return const Color(0xff168A62);
      case "rejected":
        return const Color(0xffD64B4B);
      default:
        return const Color(0xff75839A);
    }
  }

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
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xffEAF0FF),
            child: Icon(Icons.person_outline_rounded, color: Color(0xff5875E8)),
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
                  product,
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
              color: getStatusColor().withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: getStatusColor(),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
