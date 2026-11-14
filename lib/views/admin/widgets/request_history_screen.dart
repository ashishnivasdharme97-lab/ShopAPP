import 'package:flutter/material.dart';
import 'package:shop_app/models/product_request_model.dart';
import 'package:shop_app/services/product_request_service.dart';

class RequestHistoryScreen extends StatefulWidget {
  const RequestHistoryScreen({super.key});

  @override
  State<RequestHistoryScreen> createState() => _RequestHistoryScreenState();
}

class _RequestHistoryScreenState extends State<RequestHistoryScreen> {
  static const Color _green = Color(0xff168A62);
  static const Color _ink = Color(0xff1D2939);
  static const Color _muted = Color(0xff7D8999);

  List<ProductRequestModel> _requests = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final String _token = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final requests = await ProductRequestService.getRequestHistory(_token);
      if (!mounted) return;
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load request history. Please try again.';
        _isLoading = false;
      });
    }
  }

  List<ProductRequestModel> get _visibleRequests {
    final query = _searchQuery.trim().toLowerCase();
    return _requests.where((request) {
      final status = request.status.toLowerCase();
      final matchesFilter =
          _selectedFilter == 'All' || status == _selectedFilter.toLowerCase();
      final matchesSearch = query.isEmpty ||
          request.productName.toLowerCase().contains(query) ||
          request.description.toLowerCase().contains(query) ||
          request.userName.toLowerCase().contains(query) ||
          request.userId.toString().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();
  }

  int _countFor(String status) => _requests
      .where((request) => request.status.toLowerCase() == status)
      .length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xffF5F7FA),
        foregroundColor: _ink,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Request history',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh history',
            onPressed: _isLoading ? null : _loadHistory,
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading && _requests.isEmpty
          ? const Center(child: CircularProgressIndicator(color: _green))
          : RefreshIndicator(
              color: _green,
              onRefresh: _loadHistory,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 28),
                children: [
                  _buildSummary(),
                  const SizedBox(height: 20),
                  _buildSearchField(),
                  const SizedBox(height: 16),
                  _buildFilters(),
                  const SizedBox(height: 18),
                  if (_errorMessage != null)
                    _buildError()
                  else if (_visibleRequests.isEmpty)
                    _buildEmptyState()
                  else ...[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${_visibleRequests.length} '
                        '${_visibleRequests.length == 1 ? 'request' : 'requests'}',
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    for (final request in _visibleRequests)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RequestHistoryCard(request: request),
                      ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff167B59), Color(0xff20A477)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26168A62),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your requests',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'History at a glance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _SummaryMetric(label: 'Total', value: _requests.length),
              _summaryDivider(),
              _SummaryMetric(label: 'Approved', value: _countFor('approved')),
              _summaryDivider(),
              _SummaryMetric(label: 'Pending', value: _countFor('pending')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        color: Colors.white.withValues(alpha: .25),
      );

  Widget _buildSearchField() {
    return TextField(
      onChanged: (value) => setState(() => _searchQuery = value),
      decoration: InputDecoration(
        hintText: 'Search product, customer or details',
        hintStyle: const TextStyle(color: Color(0xff98A2B3), fontSize: 14),
        prefixIcon: const Icon(Icons.search_rounded, color: _muted),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xffE8ECF1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: _green, width: 1.3),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ['All', 'Pending', 'Approved', 'Rejected'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final selected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: selected,
              showCheckmark: false,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              labelStyle: TextStyle(
                color: selected ? Colors.white : const Color(0xff667085),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              selectedColor: _green,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: selected ? _green : const Color(0xffE8ECF1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 7),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildError() {
    return _StateMessage(
      icon: Icons.cloud_off_rounded,
      title: 'Unable to load history',
      message: _errorMessage!,
      action: TextButton.icon(
        onPressed: _loadHistory,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Try again'),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasCriteria =
        _searchQuery.trim().isNotEmpty || _selectedFilter != 'All';
    return _StateMessage(
      icon: hasCriteria ? Icons.search_off_rounded : Icons.inbox_outlined,
      title: hasCriteria ? 'No matching requests' : 'No request history yet',
      message: hasCriteria
          ? 'Try another search or status filter.'
          : 'Requests will appear here once they have been submitted.',
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _RequestHistoryCard extends StatelessWidget {
  const _RequestHistoryCard({required this.request});

  final ProductRequestModel request;

  Color get _statusColor {
    switch (request.status.toLowerCase()) {
      case 'approved':
        return const Color(0xff168A62);
      case 'rejected':
        return const Color(0xffD04444);
      case 'pending':
        return const Color(0xffD58A16);
      default:
        return const Color(0xff667085);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customer = request.userName.trim().isEmpty
        ? 'Customer #${request.userId}'
        : request.userName;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xffEDF0F4)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080E1B2A),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xffE9F5F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xff168A62),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff1D2939),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff7D8999),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  request.status,
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (request.description.trim().isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              request.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xff667085),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xffEEF1F4)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                color: Color(0xff98A2B3),
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                'Qty ${request.quantity}',
                style: const TextStyle(
                  color: Color(0xff667085),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.schedule_rounded,
                color: Color(0xff98A2B3),
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                _formatDate(request.createdAt),
                style: const TextStyle(
                  color: Color(0xff7D8999),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} ${date.year} · '
        '$hour:$minute $period';
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 18),
      child: Column(
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: const Color(0xffE9F5F0),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Icon(icon, color: const Color(0xff168A62), size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff1D2939),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff7D8999),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 8),
            action!,
          ],
        ],
      ),
    );
  }
}
