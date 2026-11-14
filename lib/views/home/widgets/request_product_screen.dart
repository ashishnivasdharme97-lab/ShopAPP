import 'package:flutter/material.dart';
import 'package:shop_app/services/local_notification_service.dart';
import 'package:shop_app/services/product_request_service.dart';

class RequestProductScreen extends StatefulWidget {
  const RequestProductScreen({super.key});

  @override
  State<RequestProductScreen> createState() => _RequestProductScreenState();
}

class _RequestProductScreenState extends State<RequestProductScreen> {
  String token = "";
  String selectedModule = "General Store";
  bool _isSubmitting = false;
  String? _submissionMessage;
  bool _submissionSucceeded = false;

  final TextEditingController productController = TextEditingController();
  final TextEditingController qtyController = TextEditingController();
  final TextEditingController descController = TextEditingController();

  final List<String> modules = [
    "General Store",
    "Electrical",
    "Hardware",
    "Fashion"
  ];

  @override
  void dispose() {
    productController.dispose();
    qtyController.dispose();
    descController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_isSubmitting) return;

    final productName = productController.text.trim();
    final quantity = int.tryParse(qtyController.text.trim());
    if (productName.isEmpty) {
      _showToast('Please enter product name', isError: true);
      return;
    }
    if (qtyController.text.trim().isEmpty) {
      _showToast('Please enter quantity', isError: true);
      return;
    }
    if (quantity == null || quantity <= 0) {
      _showToast('Please enter a valid quantity', isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submissionSucceeded = false;
      _submissionMessage = 'Sending your request to the server...';
    });

    try {
      final requestDescription = [
        'Module: $selectedModule',
        if (descController.text.trim().isNotEmpty) descController.text.trim(),
      ].join('\n');

      final statusCode = await ProductRequestService.createRequest(
        productName: productName,
        description: requestDescription,
        quantity: quantity,
      );
      try {
        await LocalNotificationService.add(
          audience: 'admin',
          title: 'New product request',
          message: '$productName · Qty $quantity',
        );
      } catch (error) {
        debugPrint('REQUEST NOTIFICATION SAVE ERROR: $error');
      }

      if (!mounted) return;
      setState(() {
        _submissionSucceeded = true;
        _submissionMessage =
            'Request sent to the admin. You can track it in My Requests.';
      });
      FocusScope.of(context).unfocus();
      _showToast(
        'Request submitted successfully (HTTP $statusCode).',
      );
    } catch (error, stackTrace) {
      debugPrint('REQUEST SUBMISSION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      final message = error is ProductRequestSubmissionException
          ? error.message
          : 'Could not reach the request server. Check your connection and try again.';
      setState(() {
        _submissionSucceeded = false;
        _submissionMessage = message;
      });
      _showToast('Request failed: $message', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              isError ? const Color(0xffC74646) : const Color(0xff168A62),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: isError ? 6 : 4),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      // ✅ APP BAR
      appBar: AppBar(
        title: const Text(
          "Request Product",
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
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
        child: Column(
          children: [
            // ⭐ MAIN CARD
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: const Color(0xffE9EDF2)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x080E1B2A),
                    blurRadius: 14,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tell us what you need",
                    style: TextStyle(
                      color: Color(0xff172B4D),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Share a few details and we’ll take it from there.",
                    style: TextStyle(
                      color: Color(0xff8995A8),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // MODULE
                  const Text(
                    "Select Module",
                    style: TextStyle(
                      color: Color(0xff344054),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xffF5F7FA),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: const Color(0xffE9EDF2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedModule,
                        isExpanded: true,
                        items: modules.map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedModule = value!;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                      "Product Name", productController, "Enter product name"),
                  const SizedBox(height: 12),

                  _buildField("Quantity", qtyController, "Enter quantity"),
                  const SizedBox(height: 12),

                  _buildField(
                    "Description",
                    descController,
                    "Write note...",
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            if (_submissionMessage != null) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _isSubmitting
                      ? const Color(0xffEEF4FF)
                      : _submissionSucceeded
                          ? const Color(0xffE9F5F0)
                          : const Color(0xffFDECEC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isSubmitting
                        ? const Color(0xffB8CCF5)
                        : _submissionSucceeded
                            ? const Color(0xffB8E1CD)
                            : const Color(0xffF2C2C2),
                  ),
                ),
                child: Row(
                  children: [
                    if (_isSubmitting)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xff168A62),
                        ),
                      )
                    else
                      Icon(
                        _submissionSucceeded
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                        size: 19,
                        color: _submissionSucceeded
                            ? const Color(0xff168A62)
                            : const Color(0xffC74646),
                      ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _submissionMessage!,
                        style: TextStyle(
                          color: _isSubmitting
                              ? const Color(0xff344A70)
                              : _submissionSucceeded
                                  ? const Color(0xff176B52)
                                  : const Color(0xffA93333),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 🚀 SUBMIT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff168A62),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                onPressed: _isSubmitting ? null : _submitRequest,
                child: _isSubmitting
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 19,
                            height: 19,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Sending request...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        "Submit Request",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ⭐ BEAUTIFUL INPUT FIELD
  Widget _buildField(
    String label,
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff344054),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xffF5F7FA),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xffE9EDF2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: Color(0xffE9EDF2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: Color(0xff168A62),
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
