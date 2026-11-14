import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shop_app/services/local_notification_service.dart';
import 'package:shop_app/models/product_request_model.dart';
import 'package:shop_app/services/product_request_service.dart';

class AlertScreen extends StatefulWidget {
  const AlertScreen({super.key});

  @override
  State<AlertScreen> createState() => _AlertScreenState();
}

class _AlertScreenState extends State<AlertScreen> {
  List<ProductRequestModel> _requests = [];
  List<LocalAppNotification> _notifications = [];
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadRequests();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 20),
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
      final requests = await ProductRequestService.getMyRequests('');
      if (!mounted) return;
      setState(() {
        _requests = requests;
      });
    } catch (error) {
      debugPrint('USER REQUEST NOTIFICATION ERROR: $error');
    }
    try {
      final notifications =
          await LocalNotificationService.getForAudience('user');
      if (!mounted) return;
      setState(() {
        _notifications = notifications;
      });
    } catch (error) {
      debugPrint('USER LOCAL NOTIFICATION LOAD ERROR: $error');
    }
  }

  String _formatTime(DateTime createdAt) {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes} min ago';
    if (difference.inDays < 1) return '${difference.inHours} hr ago';
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  Color _notificationColor(LocalAppNotification notification) {
    final title = notification.title.toLowerCase();
    if (title.contains('reject')) return const Color(0xffD64B4B);
    return const Color(0xff168A62);
  }

  IconData _notificationIcon(LocalAppNotification notification) {
    final title = notification.title.toLowerCase();
    if (title.contains('reject')) return Icons.cancel_outlined;
    if (title.contains('approved')) return Icons.check_circle_outline_rounded;
    return Icons.shopping_bag_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xffF5F7FA),
        foregroundColor: const Color(0xff172B4D),
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Notifications',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.notifications_active_outlined, size: 22),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff176B52), Color(0xff20A477)],
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
                        'Stay in the loop',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Important updates about your shop.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 35,
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
          for (final notification in _notifications) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xffE9EDF2)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x080E1B2A),
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
                      color: _notificationColor(notification)
                          .withValues(alpha: .1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      _notificationIcon(notification),
                      color: _notificationColor(notification),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                notification.title,
                                style: const TextStyle(
                                  color: Color(0xff243344),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _notificationColor(notification),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          notification.message,
                          style: const TextStyle(
                            color: Color(0xff75839A),
                            fontSize: 13,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 9),
                        Text(
                          _formatTime(notification.createdAt),
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
          for (final request in _requests) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 11),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xffE9EDF2)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x080E1B2A),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xffE9F5F0),
                    child: Icon(
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
                          switch (request.status.toLowerCase()) {
                            'approved' => 'Request approved',
                            'rejected' => 'Request declined',
                            _ => 'Request sent to admin',
                          },
                          style: const TextStyle(
                            color: Color(0xff243344),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${request.productName} · Qty ${request.quantity}',
                          style: const TextStyle(
                            color: Color(0xff75839A),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.circle,
                    color: Color(0xff168A62),
                    size: 7,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
