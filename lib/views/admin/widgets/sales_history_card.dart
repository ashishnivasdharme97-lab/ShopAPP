import 'package:flutter/material.dart';

class SalesHistoryCard extends StatelessWidget {
  final String date;
  final String totalSales;
  final String cash;
  final String upi;
  final String pending;

  const SalesHistoryCard({
    super.key,
    required this.date,
    required this.totalSales,
    required this.cash,
    required this.upi,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xffE8EDF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08172B4D),
            blurRadius: 13,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xffEAF5F0),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: Color(0xff168A62),
                  size: 20,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xff243344),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    "TOTAL SALES",
                    style: TextStyle(
                      color: Color(0xff8995A8),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    totalSales,
                    style: const TextStyle(
                      color: Color(0xff168A62),
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: Color(0xffEDF0F5)),
          ),
          Row(
            children: [
              Expanded(
                child: _PaymentMetric(
                  label: "Cash",
                  value: cash,
                  icon: Icons.payments_outlined,
                  color: const Color(0xff168A62),
                ),
              ),
              Expanded(
                child: _PaymentMetric(
                  label: "UPI",
                  value: upi,
                  icon: Icons.qr_code_rounded,
                  color: const Color(0xff5875E8),
                ),
              ),
              Expanded(
                child: _PaymentMetric(
                  label: "Pending",
                  value: pending,
                  icon: Icons.schedule_rounded,
                  color: const Color(0xffD98219),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaymentMetric extends StatelessWidget {
  const _PaymentMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xff75839A),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xff344054),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
