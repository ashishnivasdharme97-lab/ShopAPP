import 'package:flutter/material.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/models/dashboard_model.dart';
import 'package:shop_app/models/pending_model.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/models/product_request_model.dart';
import 'package:shop_app/services/pending_service.dart';
import 'package:shop_app/services/product_request_service.dart';
import 'package:shop_app/services/sales_service.dart';
import 'package:shop_app/views/admin/add_product_screen.dart';
import 'package:shop_app/views/admin/notification_screen.dart';
import 'package:shop_app/views/admin/widgets/request_history_screen.dart';
import 'package:shop_app/views/admin/widgets/sales_report_screen.dart';
import 'package:shop_app/views/admin/udhari_management_screen.dart';

import 'widgets/dashboard_card.dart';
import 'widgets/product_card.dart';
import 'widgets/request_card.dart';

class DashboardScreen extends StatefulWidget {
  final Function(int) onNavigate;
  final AuthSession session;
  final Future<void> Function() onLogout;

  const DashboardScreen({
    super.key,
    required this.onNavigate,
    required this.session,
    required this.onLogout,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const _ink = Color(0xff172B4D);
  static const _muted = Color(0xff75839A);
  static const _canvas = Color(0xffF4F7FB);
  static const _green = Color(0xff168A62);

  List<ProductModel> lowStockProducts = [];
  List<ProductRequestModel> pendingRequests = [];
  List<PendingModel> pendingUdhari = [];
  bool isLoadingPendingUdhari = false;
  String? pendingUdhariError;
  DashboardModel? dashboard;

  @override
  void initState() {
    super.initState();
    loadPendingRequests();
    loadPendingUdhari();
    loadDashboard();
    loadLowStockProducts();
  }

  Future<void> loadLowStockProducts() async {
    final products = await SalesService.getLowStockProducts();
    if (!mounted) return;
    setState(() {
      lowStockProducts = products;
    });
  }

  Future<void> loadPendingRequests() async {
    final requests = await ProductRequestService.getPendingRequests();
    if (!mounted) return;
    setState(() {
      pendingRequests = requests;
    });
  }

  Future<void> loadPendingUdhari() async {
    if (mounted) {
      setState(() {
        isLoadingPendingUdhari = true;
        pendingUdhariError = null;
      });
    }

    try {
      final entries = await PendingService.getPendingForAdmin(widget.session);
      if (!mounted) return;
      setState(() => pendingUdhari = entries);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        pendingUdhari = [];
        pendingUdhariError = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() => isLoadingPendingUdhari = false);
      }
    }
  }

  Future<void> loadDashboard() async {
    final result = await SalesService.getDashboard();
    if (!mounted) return;
    setState(() {
      dashboard = result;
    });
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RequestHistoryScreen()),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationScreen()),
    );
  }

  void _openSalesReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SalesReportScreen()),
    );
  }

  void _openAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
  }

  void _openUdhari() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UdhariManagementScreen(session: widget.session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dateLabel = '${today.day}/${today.month}/${today.year}';

    return Scaffold(
      backgroundColor: _canvas,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProduct,
        backgroundColor: _green,
        foregroundColor: Colors.white,
        elevation: 5,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add product',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(dateLabel),
              const SizedBox(height: 22),
              _buildOverview(),
              const SizedBox(height: 26),
              _buildRequestsSection(),
              const SizedBox(height: 26),
              _buildSalesSummary(),
              const SizedBox(height: 18),
              _buildSalesReportTile(),
              const SizedBox(height: 14),
              _buildUdhariTile(),
              const SizedBox(height: 28),
              _buildLowStockSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String dateLabel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good day, ${widget.session.shopName ?? 'Admin'}',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: _ink,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.7,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded,
                      size: 13, color: _muted),
                  const SizedBox(width: 6),
                  Text(
                    'Today · $dateLabel',
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        _HeaderAction(
          icon: Icons.history_rounded,
          tooltip: 'Request history',
          onPressed: _openHistory,
        ),
        const SizedBox(width: 9),
        _HeaderAction(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          onPressed: _openNotifications,
          showDot: true,
        ),
        const SizedBox(width: 9),
        _HeaderAction(
          icon: Icons.logout_rounded,
          tooltip: 'Sign out',
          onPressed: () {
            widget.onLogout();
          },
        ),
      ],
    );
  }

  Widget _buildOverview() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffE8EDF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A172B4D),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.insights_rounded, size: 17, color: _green),
              SizedBox(width: 7),
              Text(
                'Store overview',
                style: TextStyle(
                  color: _ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Total users',
                  value: '${dashboard?.totalUsers ?? 0}',
                  subtitle: 'Registered',
                  subtitleColor: _green,
                  icon: Icons.group_rounded,
                  iconColor: const Color(0xff5875E8),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: DashboardCard(
                  title: 'Today sales',
                  value: '₹${(dashboard?.todaySales ?? 0).toStringAsFixed(2)}',
                  subtitle: 'Today’s sale',
                  subtitleColor: _green,
                  icon: Icons.currency_rupee_rounded,
                  iconColor: _green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),
          Row(
            children: [
              Expanded(
                child: DashboardCard(
                  title: 'Collected',
                  value:
                      '₹${(dashboard?.todayCollected ?? 0).toStringAsFixed(2)}',
                  subtitle: 'Payments received',
                  subtitleColor: const Color(0xff5875E8),
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xff5875E8),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: DashboardCard(
                  title: 'Pending requests',
                  value: '${pendingRequests.length}',
                  subtitle: 'Needs attention',
                  subtitleColor: const Color(0xffD98219),
                  icon: Icons.pending_actions_rounded,
                  iconColor: const Color(0xffD98219),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: 'Recent requests',
          subtitle: '${pendingRequests.length} awaiting review',
          actionLabel: 'View all',
          onAction: () => widget.onNavigate(1),
        ),
        const SizedBox(height: 12),
        if (pendingRequests.isEmpty)
          const _EmptyState(
            icon: Icons.task_alt_rounded,
            message: 'You’re all caught up',
            detail: 'New product requests will appear here.',
          )
        else
          ...pendingRequests.take(2).map(
                (request) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: RequestCard(
                    name: request.userName,
                    product: '${request.productName} (${request.quantity})',
                    status: request.status,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildSalesSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeading(
          title: 'Today’s sales',
          subtitle: 'Payment breakdown',
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          decoration: _cardDecoration(),
          child: Column(
            children: [
              _PaymentRow(
                icon: Icons.payments_outlined,
                label: 'Cash',
                amount: dashboard?.todayCash ?? 0,
                color: _green,
              ),
              const Divider(height: 1, color: Color(0xffEDF0F5)),
              _PaymentRow(
                icon: Icons.qr_code_rounded,
                label: 'UPI',
                amount: dashboard?.todayUpi ?? 0,
                color: const Color(0xff5875E8),
              ),
              const Divider(height: 1, color: Color(0xffEDF0F5)),
              _PaymentRow(
                icon: Icons.schedule_rounded,
                label: 'Pending',
                amount: dashboard?.todayPending ?? 0,
                color: const Color(0xffD98219),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSalesReportTile() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openSalesReport,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xff173B35), Color(0xff168A62)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x28168A62),
                blurRadius: 16,
                offset: Offset(0, 7),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sales reports',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Explore your store performance',
                      style: TextStyle(
                        color: Color(0xffC9E8DC),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUdhariTile() {
    final groupedByDay = <DateTime, List<PendingModel>>{};
    for (final entry in pendingUdhari) {
      if (entry.status.trim().toLowerCase() != 'pending') continue;

      final date = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      (groupedByDay[date] ??= []).add(entry);
    }

    final sortedDays = groupedByDay.keys.toList()
      ..sort((first, second) => second.compareTo(first));
    final total = groupedByDay.values
        .expand((entries) => entries)
        .fold<double>(0, (sum, entry) => sum + entry.amount);
    final pendingCount = groupedByDay.values
        .fold<int>(0, (count, entries) => count + entries.length);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _openUdhari,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffE8EDF4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xffEAF5F0),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: _green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Udhari',
                          style: TextStyle(
                            color: _ink,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isLoadingPendingUdhari
                              ? 'Loading pending records...'
                              : pendingUdhariError ??
                                  '$pendingCount pending records',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: _muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    isLoadingPendingUdhari || pendingUdhariError != null
                        ? '—'
                        : '₹${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: _ink,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 15, color: _muted),
                ],
              ),
              if (!isLoadingPendingUdhari && pendingUdhariError == null) ...[
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xffE8EDF4)),
                if (sortedDays.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'No pending Udhari records.',
                      style: TextStyle(color: _muted, fontSize: 12),
                    ),
                  )
                else
                  for (final day in sortedDays) ...[
                    const SizedBox(height: 12),
                    _buildUdhariDay(day, groupedByDay[day]!),
                  ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUdhariDay(DateTime day, List<PendingModel> entries) {
    final customerTotals = <String, double>{};
    for (final entry in entries) {
      final customerName = entry.customerName.trim().isEmpty
          ? 'Customer'
          : entry.customerName.trim();
      customerTotals.update(
        customerName,
        (amount) => amount + entry.amount,
        ifAbsent: () => entry.amount,
      );
    }

    final dayTotal =
        entries.fold<double>(0, (sum, entry) => sum + entry.amount);
    final customerNames = customerTotals.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${day.day}/${day.month}/${day.year}',
                style: const TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '₹${dayTotal.toStringAsFixed(2)}',
              style: const TextStyle(
                color: _green,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        for (final customerName in customerNames)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Row(
              children: [
                const Icon(Icons.person_outline_rounded,
                    size: 15, color: _muted),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    customerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 12),
                  ),
                ),
                Text(
                  '₹${customerTotals[customerName]!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLowStockSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeading(
          title: 'Low stock',
          subtitle: '${lowStockProducts.length} products need a restock',
        ),
        const SizedBox(height: 12),
        if (lowStockProducts.isEmpty)
          const _EmptyState(
            icon: Icons.inventory_2_outlined,
            message: 'Stock levels look good',
            detail: 'Products running low will show up here.',
          )
        else
          ...lowStockProducts.map(
            (product) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ProductCard(
                name: product.productName,
                store: product.categoryName,
                stock: product.quantity.toString(),
              ),
            ),
          ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(19),
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

class _HeaderAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool showDot;

  const _HeaderAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: SizedBox(
            width: 45,
            height: 45,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, color: const Color(0xff344563), size: 22),
                if (showDot)
                  Positioned(
                    right: 11,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xffE45757),
                        shape: BoxShape.circle,
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
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xff172B4D),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xff75839A),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xff168A62),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              textStyle:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double amount;
  final Color color;

  const _PaymentRow({
    required this.icon,
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
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
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xff53627A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xff172B4D),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String detail;

  const _EmptyState({
    required this.icon,
    required this.message,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffE8EDF4)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 25, color: const Color(0xff8A97AA)),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: Color(0xff344563),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            detail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff75839A),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
