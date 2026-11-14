import 'package:flutter/material.dart';
import 'package:shop_app/models/product_report_model.dart';
import 'package:shop_app/models/sale_report_model.dart';
import 'package:shop_app/models/sales_summary_model.dart';
import 'package:shop_app/services/report_service.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  static const _canvas = Color(0xffF4F7FB);
  static const _ink = Color(0xff172B4D);
  static const _muted = Color(0xff75839A);
  static const _green = Color(0xff168A62);

  String selectedPeriod = 'daily';
  bool isLoading = true;
  SalesSummaryModel? summary;
  List<ProductReportModel> products = [];
  List<SaleReportModel> bills = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });

    final reportSummary = await ReportService.getSummary(selectedPeriod);
    final reportProducts = await ReportService.getProductReport(selectedPeriod);
    final reportBills = await ReportService.getBillReport(selectedPeriod);

    if (!mounted) return;
    setState(() {
      summary = reportSummary;
      products = reportProducts;
      bills = reportBills;
      isLoading = false;
    });
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
          'Sales report',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: _ink,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _green),
            )
          : RefreshIndicator(
              color: _green,
              onRefresh: loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHero(),
                    const SizedBox(height: 20),
                    _buildPeriodSelector(),
                    const SizedBox(height: 22),
                    const _SectionHeading(
                      title: 'Performance',
                      subtitle: 'A quick look at your store',
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryCards(),
                    const SizedBox(height: 26),
                    _SectionHeading(
                      title: 'Top products',
                      subtitle: '${products.length} products in this report',
                    ),
                    const SizedBox(height: 12),
                    _buildProducts(),
                    const SizedBox(height: 26),
                    _SectionHeading(
                      title: 'Recent bills',
                      subtitle: '${bills.length} bills in this report',
                    ),
                    const SizedBox(height: 12),
                    _buildBills(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHero() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff173B35), Color(0xff168A62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25168A62),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales overview',
                  style: TextStyle(
                    color: Color(0xffD3EFE2),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${(summary?.totalSales ?? 0).toStringAsFixed(2)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${_periodLabel(selectedPeriod)} · ${summary?.totalBills ?? 0} bills',
                  style: const TextStyle(
                    color: Color(0xffD3EFE2),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.trending_up_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xffE8EDF4)),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: selectedPeriod,
        isExpanded: true,
        decoration: const InputDecoration(
          labelText: 'Report period',
          prefixIcon: Icon(Icons.calendar_month_rounded, color: _green),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        items: const [
          DropdownMenuItem(value: 'daily', child: Text('Daily')),
          DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
          DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
          DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
          DropdownMenuItem(value: 'overall', child: Text('Overall')),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() {
            selectedPeriod = value;
          });
          loadData();
        },
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 11,
      mainAxisSpacing: 11,
      childAspectRatio: 1.37,
      children: [
        _SummaryCard(
          title: 'Collected',
          value: '₹${(summary?.collectedAmount ?? 0).toStringAsFixed(2)}',
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xff5875E8),
        ),
        _SummaryCard(
          title: 'Pending',
          value: '₹${(summary?.pendingAmount ?? 0).toStringAsFixed(2)}',
          icon: Icons.pending_actions_rounded,
          color: const Color(0xffD98219),
        ),
        _SummaryCard(
          title: 'Bills',
          value: '${summary?.totalBills ?? 0}',
          icon: Icons.receipt_long_rounded,
          color: _green,
        ),
        _SummaryCard(
          title: 'Items sold',
          value: '${summary?.productsSold ?? 0}',
          icon: Icons.inventory_2_rounded,
          color: const Color(0xff8657C5),
        ),
      ],
    );
  }

  Widget _buildProducts() {
    if (products.isEmpty) {
      return const _EmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'No product sales yet',
        subtitle: 'Products sold during this period will appear here.',
      );
    }

    return Column(
      children: products.map((product) {
        final stockColor =
            product.currentStock <= 5 ? const Color(0xffD84A4A) : _green;
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xffEAF5F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: _green,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${product.totalQuantitySold} sold · ${product.currentStock} in stock',
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${product.totalSaleAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock ${product.currentStock}',
                    style: TextStyle(
                      color: stockColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBills() {
    if (bills.isEmpty) {
      return const _EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No bills found',
        subtitle: 'Bills generated during this period will appear here.',
      );
    }

    return Column(
      children: bills.map((bill) {
        final isCash = bill.paymentMode.toLowerCase() == 'cash';
        final paymentColor = isCash ? _green : const Color(0xff5875E8);
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xffEEF2FF),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xff5875E8),
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.billNo,
                          style: const TextStyle(
                            color: _ink,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${bill.createdAt.day}/${bill.createdAt.month}/${bill.createdAt.year}',
                          style: const TextStyle(color: _muted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${bill.grandTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: _ink,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: paymentColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          bill.paymentMode,
                          style: TextStyle(
                            color: paymentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 13),
                child: Divider(height: 1, color: Color(0xffEDF0F5)),
              ),
              _BillAmountRow(
                label: 'Paid',
                value: bill.paidAmount,
                color: _green,
              ),
              const SizedBox(height: 9),
              _BillAmountRow(
                label: 'Pending',
                value: bill.remainingAmount,
                color: const Color(0xffD98219),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xffE8EDF4)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x08172B4D),
          blurRadius: 14,
          offset: Offset(0, 5),
        ),
      ],
    );
  }

  String _periodLabel(String period) {
    switch (period) {
      case 'weekly':
        return 'This week';
      case 'monthly':
        return 'This month';
      case 'yearly':
        return 'This year';
      case 'overall':
        return 'All time';
      default:
        return 'Today';
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
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
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _SalesReportScreenState._muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _SalesReportScreenState._ink,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _SalesReportScreenState._ink,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: _SalesReportScreenState._muted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE8EDF4)),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xff8491A5), size: 27),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(
              color: _SalesReportScreenState._ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _SalesReportScreenState._muted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BillAmountRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _BillAmountRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _SalesReportScreenState._muted,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          '₹${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
