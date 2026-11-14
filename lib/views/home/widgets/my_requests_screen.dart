import 'package:flutter/material.dart';
import 'package:shop_app/models/product_request_model.dart';
import 'package:shop_app/services/product_request_service.dart';

class MyRequestsScreen extends StatefulWidget {
  final ProductRequestModel? initialRequest;

  const MyRequestsScreen({
    super.key,
    this.initialRequest,
  });

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  String selectedTab = "Pending";
  List<ProductRequestModel> requests = [];
  bool isLoading = false;
  String? loadError;
  String token = "";

  @override
  void initState() {
    super.initState();
    if (widget.initialRequest != null) {
      requests = [widget.initialRequest!];
    } else {
      isLoading = true;
    }
    loadRequests();
  }

  Future<void> loadRequests() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      loadError = null;
    });

    try {
      final serverRequests = await ProductRequestService.getMyRequests(token);
      if (!mounted) return;

      final mergedRequests = [...requests];
      for (final request in serverRequests) {
        if (!mergedRequests.any((existing) => existing.id == request.id)) {
          mergedRequests.add(request);
        }
      }

      setState(() {
        requests = mergedRequests;
        isLoading = false;
      });
    } catch (error) {
      debugPrint('MY REQUESTS LOAD ERROR: $error');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        loadError = error is ProductRequestLoadException
            ? error.message
            : 'Could not load your requests. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredRequests = requests.where((item) {
      return item.status.trim().toLowerCase() ==
          selectedTab.trim().toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xffF5F7FA),
        foregroundColor: const Color(0xff172B4D),
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          "My Requests",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            onPressed: isLoading ? null : loadRequests,
            tooltip: 'Refresh requests',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.receipt_long_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xffE9EDF2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  buildTab("Pending"),
                  buildTab("Approved"),
                  buildTab("Rejected"),
                ],
              ),
            ),
            const SizedBox(height: 19),
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xff168A62),
                      ),
                    )
                  : loadError != null
                      ? _buildLoadError()
                      : filteredRequests.isEmpty
                          ? _buildEmptyState()
                          : ListView.separated(
                              padding: const EdgeInsets.only(bottom: 20),
                              itemCount: filteredRequests.length,
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 11),
                              itemBuilder: (context, index) {
                                final item = filteredRequests[index];
                                final statusColor =
                                    switch (item.status.trim().toLowerCase()) {
                                  "approved" => const Color(0xff168A62),
                                  "rejected" => const Color(0xffD64B4B),
                                  _ => const Color(0xffD58A16),
                                };

                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xffE9EDF2),
                                    ),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x080E1B2A),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffE9F5F0),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.inventory_2_outlined,
                                          color: Color(0xff168A62),
                                          size: 21,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.productName,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Color(0xff243344),
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              "Quantity: ${item.quantity}",
                                              style: const TextStyle(
                                                color: Color(0xff667085),
                                                fontSize: 12,
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              item.createdAt.toString(),
                                              style: const TextStyle(
                                                color: Color(0xff98A2B3),
                                                fontSize: 11,
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
                                          color:
                                              statusColor.withValues(alpha: .1),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          item.status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: Color(0xffC74646),
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Requests could not be loaded',
              style: TextStyle(
                color: Color(0xff243344),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              loadError!,
              style: const TextStyle(
                color: Color(0xff8995A8),
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: loadRequests,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xff168A62),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: const Color(0xffE9F5F0),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.inbox_outlined,
              color: Color(0xff168A62),
              size: 31,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "No requests found",
            style: TextStyle(
              color: Color(0xff243344),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "There are no ${selectedTab.toLowerCase()} requests right now.",
            style: const TextStyle(color: Color(0xff8995A8), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget buildTab(String title) {
    final isSelected = selectedTab == title;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = title;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
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
              title,
              style: TextStyle(
                color: isSelected
                    ? const Color(0xff168A62)
                    : const Color(0xff75839A),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
