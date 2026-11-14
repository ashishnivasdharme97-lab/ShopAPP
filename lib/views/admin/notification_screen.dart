import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop_app/models/product_request_model.dart';
import 'package:shop_app/services/local_notification_service.dart';
import 'package:shop_app/services/product_request_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<ProductRequestModel> _requests = [];
  List<LocalAppNotification> _notifications = [];
  bool _hasLoadedRequests = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadRequests(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRequests() async {
    try {
      final requests = await ProductRequestService.getPendingRequests();
      if (!mounted) return;
      final knownIds = _requests.map((request) => request.id).toSet();
      final newRequests = _hasLoadedRequests
          ? requests
              .where((request) =>
                  !knownIds.contains(request.id) &&
                  request.status.trim().toLowerCase() == 'pending')
              .toList()
          : <ProductRequestModel>[];
      setState(() {
        _requests = requests;
        _hasLoadedRequests = true;
      });
      if (newRequests.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'New product request: ${newRequests.first.productName}',
              ),
              backgroundColor: const Color(0xff168A62),
            ),
          );
      }
    } catch (error) {
      debugPrint('ADMIN REQUEST NOTIFICATION ERROR: $error');
    }
    try {
      final notifications =
          await LocalNotificationService.getForAudience('admin');
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
      });
    } catch (error) {
      debugPrint('ADMIN LOCAL NOTIFICATION LOAD ERROR: $error');
    }
  }

  Color _notificationColor(LocalAppNotification notification) {
    final title = notification.title.toLowerCase();
    if (title.contains('request')) return const Color(0xffD98219);
    return const Color(0xff168A62);
  }

  IconData _notificationIcon(LocalAppNotification notification) {
    if (notification.title.toLowerCase().contains('request')) {
      return Icons.inventory_2_outlined;
    }
    return Icons.shopping_bag_outlined;
  }

  String _formatTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes} min ago';
    if (difference.inDays < 1) return '${difference.inHours} hr ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xffF4F7FB),
        foregroundColor: const Color(0xff172B4D),
        titleSpacing: 20,
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: _loadRequests,
            tooltip: 'Refresh notifications',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
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
                        'Stay up to date',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'The latest updates from your store.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Recent activity',
            style: TextStyle(
              color: Color(0xff172B4D),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          for (final request in _requests)
            Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(15),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xffD98219).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xffD98219),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'New product request',
                          style: TextStyle(
                            color: Color(0xff243344),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${request.productName} · Qty ${request.quantity}'
                          '${request.userName.trim().isEmpty ? '' : ' · ${request.userName}'}',
                          style: const TextStyle(
                            color: Color(0xff75839A),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        if (request.description.trim().isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            request.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xff75839A),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          for (final item in _notifications)
            Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(15),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _notificationColor(item).withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      _notificationIcon(item),
                      color: _notificationColor(item),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            color: Color(0xff243344),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.message,
                          style: const TextStyle(
                            color: Color(0xff75839A),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          _formatTime(item.createdAt),
                          style: const TextStyle(
                            color: Color(0xff98A2B3),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
