import 'package:flutter/material.dart';
import 'package:shop_app/views/admin/widgets/sales_history_card.dart';

class SalesHistoryScreen extends StatelessWidget {
  const SalesHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),
      appBar: AppBar(
        title: const Text(
          "Sales history",
          style: TextStyle(
            color: Color(0xff172B4D),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: const Color(0xffF4F7FB),
        elevation: 0,
        foregroundColor: const Color(0xff172B4D),
        titleSpacing: 20,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff173B35), Color(0xff168A62)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Sales at a glance",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Review your recent daily performance.",
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.trending_up_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ],
            ),
          ),
          const SizedBox(height: 21),
          const Text(
            "Recent days",
            style: TextStyle(
              color: Color(0xff172B4D),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          SalesHistoryCard(
            date: "06 June 2026",
            totalSales: "₹14,750",
            cash: "₹8,500",
            upi: "₹4,000",
            pending: "₹2,250",
          ),
          const SizedBox(height: 12),
          SalesHistoryCard(
            date: "05 June 2026",
            totalSales: "₹12,300",
            cash: "₹7,000",
            upi: "₹3,800",
            pending: "₹1,500",
          ),
          SizedBox(height: 12),
          SalesHistoryCard(
            date: "04 June 2026",
            totalSales: "₹18,900",
            cash: "₹10,000",
            upi: "₹6,500",
            pending: "₹2,400",
          ),
        ],
      ),
    );
  }
}
