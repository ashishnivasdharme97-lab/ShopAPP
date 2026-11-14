import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop_app/models/product_request_model.dart';
import 'package:shop_app/services/local_notification_service.dart';
import 'package:shop_app/services/product_request_service.dart';

class RequestManagementScreen extends StatefulWidget {
  const RequestManagementScreen({super.key});

  @override
  State<RequestManagementScreen> createState() =>
      _RequestManagementScreenState();
}

class _RequestManagementScreenState extends State<RequestManagementScreen> {
  static const _canvas = Color(0xffF4F7FB);
  static const _ink = Color(0xff172B4D);
  static const _muted = Color(0xff75839A);
  static const _green = Color(0xff168A62);

  List<ProductRequestModel> requests = [];
  bool isLoading = true;
  String token = '';
  String selectedStatus = 'Pending';
  String? _historyLoadError;
  Timer? _requestRefreshTimer;

  @override
  void initState() {
    super.initState();
    loadRequests();
    _requestRefreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _refreshRequests(),
    );
  }

  @override
  void dispose() {
    _requestRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> loadRequests() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final pending = await ProductRequestService.getPendingRequests();
      var history = <ProductRequestModel>[];
      String? historyError;
      try {
        history = await ProductRequestService.getRequestHistory(token);
      } catch (error) {
        historyError = error.toString();
        debugPrint('REQUEST HISTORY LOAD ERROR: $error');
      }
      if (!mounted) return;
      setState(() {
        requests = _mergeRequests(pending, history);
        _historyLoadError = historyError;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('REQUEST LOAD ERROR: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load request history. Please retry.'),
          backgroundColor: Color(0xffC74646),
        ),
      );
    }
  }

  Future<void> _refreshRequests() async {
    try {
      final pending = await ProductRequestService.getPendingRequests();
      var history = <ProductRequestModel>[];
      String? historyError;
      try {
        history = await ProductRequestService.getRequestHistory(token);
      } catch (error) {
        historyError = error.toString();
        debugPrint('REQUEST HISTORY REFRESH ERROR: $error');
        history = requests
            .where(
                (request) => request.status.trim().toLowerCase() != 'pending')
            .toList();
      }
      final result = _mergeRequests(pending, history);
      if (!mounted) return;

      final currentIds = requests.map((request) => request.id).toSet();
      final newRequests = result
          .where((request) =>
              !currentIds.contains(request.id) &&
              request.status.toLowerCase() == 'pending')
          .toList();

      final requestsChanged = !_sameRequests(requests, result);
      if (requestsChanged || _historyLoadError != historyError) {
        setState(() {
          requests = result;
          _historyLoadError = historyError;
        });
      }

      if (newRequests.isNotEmpty) {
        final latestRequest = newRequests.first;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'New product request: ${latestRequest.productName}',
              ),
              backgroundColor: _green,
            ),
          );
      }
    } catch (e) {
      debugPrint('REQUEST REFRESH ERROR: $e');
    }
  }

  Future<void> acceptRequest(ProductRequestModel request) async {
    try {
      final success =
          await ProductRequestService.approveRequest(request.id, token);
      if (!mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to accept request'),
            backgroundColor: Color(0xffC74646),
          ),
        );
        return;
      }
      try {
        await LocalNotificationService.add(
          audience: 'user',
          title: 'Request approved',
          message: '${request.productName} request was approved.',
        );
      } catch (error) {
        debugPrint('APPROVAL NOTIFICATION SAVE ERROR: $error');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${request.productName} request accepted'),
          backgroundColor: _green,
        ),
      );
      await loadRequests();
    } catch (e) {
      debugPrint('ACCEPT ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to accept request'),
          backgroundColor: Color(0xffC74646),
        ),
      );
    }
  }

  Future<void> rejectRequest(ProductRequestModel request) async {
    try {
      final success =
          await ProductRequestService.rejectRequest(request.id, token);
      if (!mounted) return;
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to reject request'),
            backgroundColor: Color(0xffC74646),
          ),
        );
        return;
      }
      try {
        await LocalNotificationService.add(
          audience: 'user',
          title: 'Request rejected',
          message: '${request.productName} request was rejected.',
        );
      } catch (error) {
        debugPrint('REJECTION NOTIFICATION SAVE ERROR: $error');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${request.productName} request rejected'),
          backgroundColor: const Color(0xffC74646),
        ),
      );
      await loadRequests();
    } catch (e) {
      debugPrint('REJECT ERROR: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to reject request'),
          backgroundColor: Color(0xffC74646),
        ),
      );
    }
  }

  int get pendingCount => requests
      .where((request) => request.status.trim().toLowerCase() == 'pending')
      .length;

  List<ProductRequestModel> get visibleRequests => requests
      .where((request) =>
          request.status.trim().toLowerCase() == selectedStatus.toLowerCase())
      .toList();

  List<ProductRequestModel> _mergeRequests(
    List<ProductRequestModel> pending,
    List<ProductRequestModel> history,
  ) {
    final merged = <int, ProductRequestModel>{
      for (final request in history) request.id: request,
      for (final request in pending) request.id: request,
    };
    return merged.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  bool _sameRequests(
    List<ProductRequestModel> first,
    List<ProductRequestModel> second,
  ) {
    if (first.length != second.length) return false;
    for (var index = 0; index < first.length; index++) {
      final a = first[index];
      final b = second[index];
      if (a.id != b.id ||
          a.productName != b.productName ||
          a.description != b.description ||
          a.status != b.status ||
          a.userId != b.userId ||
          a.userName != b.userName ||
          a.quantity != b.quantity ||
          a.createdAt != b.createdAt) {
        return false;
      }
    }
    return true;
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
          'Product requests',
          style: TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: isLoading ? null : loadRequests,
              tooltip: 'Refresh requests',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _ink,
              ),
              icon: const Icon(Icons.refresh_rounded),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _green),
            )
          : RefreshIndicator(
              color: _green,
              onRefresh: loadRequests,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 5, 18, 28),
                children: [
                  if (requests.isNotEmpty) ...[
                    _buildOverview(),
                    const SizedBox(height: 22),
                  ],
                  _buildStatusTabs(),
                  if (_historyLoadError != null &&
                      selectedStatus.toLowerCase() != 'pending') ...[
                    const SizedBox(height: 10),
                    _buildHistoryError(),
                  ],
                  const SizedBox(height: 22),
                  if (requests.isEmpty)
                    _buildEmptyStatus()
                  else ...[
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Requests',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${visibleRequests.length} total',
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (visibleRequests.isEmpty)
                      _buildEmptyStatus()
                    else
                      ...visibleRequests.map(_buildRequestCard),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildHistoryError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffFFF4E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Could not refresh approved/rejected requests: $_historyLoadError',
        style: const TextStyle(
          color: Color(0xff8A5700),
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildStatusTabs() {
    const statuses = ['Pending', 'Approved', 'Rejected'];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xffE9EDF2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: statuses.map((status) {
          final isSelected = selectedStatus == status;
          final count = requests
              .where((request) =>
                  request.status.trim().toLowerCase() == status.toLowerCase())
              .length;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (selectedStatus != status) {
                  setState(() => selectedStatus = status);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0x10172B4D),
                            blurRadius: 7,
                            offset: Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    '$status ($count)',
                    style: TextStyle(
                      color: isSelected ? _green : _muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyStatus() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 20),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, color: _muted, size: 36),
          const SizedBox(height: 10),
          Text(
            'No ${selectedStatus.toLowerCase()} requests',
            style: const TextStyle(
              color: _ink,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff173B35), Color(0xff168A62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(23),
        boxShadow: const [
          BoxShadow(
            color: Color(0x25168A62),
            blurRadius: 17,
            offset: Offset(0, 7),
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
                  'Keep your catalogue growing',
                  style: TextStyle(
                    color: Color(0xffD4EEE2),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '$pendingCount pending ${pendingCount == 1 ? 'request' : 'requests'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${requests.length} product requests received',
                  style: const TextStyle(
                    color: Color(0xffD4EEE2),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.inventory_2_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(ProductRequestModel request) {
    final status = request.status.trim();
    final isPending = status.toLowerCase() == 'pending';
    final statusColor = isPending
        ? const Color(0xffD98219)
        : status.toLowerCase() == 'approved'
            ? _green
            : const Color(0xffC74646);

    return Container(
      key: ValueKey(request.id),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffE8EDF4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08172B4D),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xffEAF5F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: _green,
                  size: 23,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.productName.trim(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Requested ${_formatDate(request.createdAt)}',
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(label: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoPill(
                icon: Icons.inventory_2_outlined,
                label: 'Qty ${request.quantity}',
                color: const Color(0xff5875E8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoPill(
                  icon: Icons.person_outline_rounded,
                  label: request.userName.trim().isEmpty
                      ? 'User ${request.userId}'
                      : request.userName.trim(),
                  color: const Color(0xff8657C5),
                ),
              ),
            ],
          ),
          if (request.description.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xffF7F9FC),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.notes_rounded,
                    color: _muted,
                    size: 17,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      request.description.trim(),
                      style: const TextStyle(
                        color: Color(0xff53627A),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (isPending) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Divider(height: 1, color: Color(0xffEDF0F5)),
            ),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 43,
                    child: ElevatedButton.icon(
                      onPressed: () => acceptRequest(request),
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 43,
                    child: OutlinedButton.icon(
                      onPressed: () => rejectRequest(request),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xffC74646),
                        side: const BorderSide(color: Color(0xffF0D7D7)),
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
