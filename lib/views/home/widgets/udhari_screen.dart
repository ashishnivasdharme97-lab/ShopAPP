import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/controllers/auth_controller.dart';
import 'package:shop_app/controllers/udhari_controller.dart';

class UdhariScreen extends StatefulWidget {
  const UdhariScreen({super.key});

  @override
  State<UdhariScreen> createState() => _UdhariScreenState();
}

class _UdhariScreenState extends State<UdhariScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUdhari());
  }

  Future<void> _loadUdhari() async {
    final session = context.read<AuthController>().session;
    if (session == null) return;
    await context.read<UdhariController>().loadMyEntries(session);
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<UdhariController>();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        title: const Text(
          "My Udhari",
          style: TextStyle(
            color: Color(0xff172B4D),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xffF5F7FA),
        foregroundColor: const Color(0xff172B4D),
        elevation: 0,
        titleSpacing: 20,
        actions: [
          IconButton(
            onPressed: controller.isLoading ? null : _loadUdhari,
            tooltip: 'Refresh Udhari',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(18, 8, 18, 16),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff176B52), Color(0xff20A477)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x24168A62),
                  blurRadius: 16,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Colors.white70,
                      size: 19,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Total Outstanding",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "₹ ${controller.totalUdhari.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent transactions",
                style: TextStyle(
                  color: Color(0xff172B4D),
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Expanded(
            child: controller.isLoading
                ? const Center(child: CircularProgressIndicator())
                : controller.errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            controller.errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xff8995A8)),
                          ),
                        ),
                      )
                    : controller.entries.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(28),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.receipt_long_outlined,
                                    color: Color(0xff168A62),
                                    size: 42,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "No transactions yet",
                                    style: TextStyle(
                                      color: Color(0xff243344),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Bills with an outstanding balance will appear here.",
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
                        : RefreshIndicator(
                            onRefresh: _loadUdhari,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: controller.entries.length,
                              itemBuilder: (context, index) {
                                final item = controller.entries[index];
                                final billReference =
                                    item.billReference.isNotEmpty
                                        ? item.billReference
                                        : item.billId;

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 6,
                                  ),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(17),
                                    border: Border.all(
                                      color: const Color(0xffE9EDF2),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        blurRadius: 10,
                                        color: Color(0x080E1B2A),
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 42,
                                        height: 42,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffFDEEEE),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.receipt_long_rounded,
                                          color: Color(0xffD64B4B),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              billReference.isEmpty
                                                  ? 'Bill'
                                                  : 'Bill $billReference',
                                              style: const TextStyle(
                                                color: Color(0xff243344),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              item.customerName,
                                              style: const TextStyle(
                                                color: Color(0xff8995A8),
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            _amountLine(
                                              'Total',
                                              item.totalAmount,
                                            ),
                                            _amountLine(
                                              'Paid',
                                              item.paidAmount,
                                            ),
                                            _amountLine(
                                              'Remaining',
                                              item.remainingAmount,
                                              emphasize: true,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              'Due: ${_formatDate(item.dueDate)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Color(0xff8995A8),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _amountLine(
    String label,
    double amount, {
    bool emphasize = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: emphasize
                    ? const Color(0xffD64B4B)
                    : const Color(0xff8995A8),
                fontSize: 12,
                fontWeight: emphasize ? FontWeight.w700 : FontWeight.normal,
              ),
            ),
          ),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color:
                  emphasize ? const Color(0xffD64B4B) : const Color(0xff243344),
              fontSize: 12,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day}/${date.month}/${date.year}';
  }
}
