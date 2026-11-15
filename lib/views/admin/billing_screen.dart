import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/models/create_sale_model.dart';
import 'package:shop_app/models/create_pending_model.dart';
import 'package:shop_app/models/product_model.dart';
import 'package:shop_app/models/registered_user_model.dart';
import 'package:shop_app/services/pdf_service.dart';
import 'package:shop_app/services/product_service.dart';
import 'package:shop_app/services/pending_service.dart';
import 'package:shop_app/services/registered_user_service.dart';
import 'package:shop_app/services/sales_service.dart';
import 'package:shop_app/views/admin/add_product_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key, required this.session});

  final AuthSession session;

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  //---------------- Controllers ----------------//

  final TextEditingController productSearchController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  final TextEditingController rateController = TextEditingController();

  final TextEditingController qtyController = TextEditingController();

  final TextEditingController customerController = TextEditingController();
  final TextEditingController pendingCustomerController =
      TextEditingController();
  final FocusNode customerFocusNode = FocusNode();
  final FocusNode pendingCustomerFocusNode = FocusNode();

  final TextEditingController paidController = TextEditingController();

  final TextEditingController pendingAmountController = TextEditingController();

  //---------------- Variables ----------------//

  List<ProductModel> products = [];
  List<RegisteredUserModel> registeredUsers = [];

  ProductModel? selectedProduct;

  List<ProductModel> filteredProducts = [];
  List<String> customerSuggestions = [];
  String? customerSuggestionsError;
  bool isLoadingCustomerSuggestions = false;

  bool showProductSuggestions = false;
  bool isLoadingProducts = true;
  bool isLoadingRegisteredUsers = true;
  bool isSubmittingBill = false;
  String paymentMode = "Cash";
  String? registeredUsersError;
  RegisteredUserModel? selectedRegisteredUser;
  DateTime? dueDate;
  CreateSaleModel? _retryBill;
  List<Map<String, dynamic>>? _retryBillItems;

  late final RegisteredUserService _registeredUserService;
  late final SalesService _salesService;

  List<Map<String, dynamic>> billItems = [];

  double grandTotal = 0;

  double remaining = 0;

  @override
  void initState() {
    super.initState();
    _registeredUserService = RegisteredUserService();
    _salesService = SalesService();
    loadProducts();
    loadRegisteredUsers();
    loadCustomerSuggestions();
  }

  @override
  void dispose() {
    customerController.dispose();
    pendingCustomerController.dispose();
    customerFocusNode.dispose();
    pendingCustomerFocusNode.dispose();
    productSearchController.dispose();
    rateController.dispose();
    qtyController.dispose();
    paidController.dispose();
    pendingAmountController.dispose();
    _registeredUserService.close();
    _salesService.close();
    super.dispose();
  }

  Future<void> loadRegisteredUsers() async {
    setState(() {
      isLoadingRegisteredUsers = true;
      registeredUsersError = null;
    });
    try {
      final users = await _registeredUserService.getUsers(widget.session);
      if (!mounted) return;
      setState(() {
        registeredUsers = users;
        if (selectedRegisteredUser != null &&
            !users.any((user) => user.id == selectedRegisteredUser!.id)) {
          selectedRegisteredUser = null;
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => registeredUsersError = error.toString());
    } finally {
      if (mounted) setState(() => isLoadingRegisteredUsers = false);
    }
  }

  Future<void> loadCustomerSuggestions() async {
    setState(() => isLoadingCustomerSuggestions = true);
    try {
      final entries = await PendingService.getPendingForAdmin(widget.session);
      if (!mounted) return;

      final names = entries
          .map((entry) => entry.customerName.trim())
          .where((name) => name.isNotEmpty)
          .toSet()
          .toList()
        ..sort((first, second) => first.toLowerCase().compareTo(
              second.toLowerCase(),
            ));

      setState(() {
        customerSuggestions = names;
        customerSuggestionsError = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => customerSuggestionsError = error.toString());
    } finally {
      if (mounted) {
        setState(() => isLoadingCustomerSuggestions = false);
      }
    }
  }

  void _rememberCustomerName(String value) {
    final name = value.trim();
    if (name.isEmpty ||
        customerSuggestions.any(
          (existing) => existing.toLowerCase() == name.toLowerCase(),
        )) {
      return;
    }

    setState(() {
      customerSuggestions = [...customerSuggestions, name]
        ..sort((first, second) => first.toLowerCase().compareTo(
              second.toLowerCase(),
            ));
    });
  }

  Future<void> loadProducts() async {
    if (mounted) {
      setState(() {
        isLoadingProducts = true;
      });
    }

    products = await ProductService.getProducts();

    if (!mounted) return;

    setState(() {
      filteredProducts = [];
      showProductSuggestions = false;
      isLoadingProducts = false;
    });
  }

  Future<void> _openAddProduct() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) => const AddProductScreen(),
      ),
    );
    if (mounted) await loadProducts();
  }
  //---------------- Decoration ----------------//

  InputDecoration fieldDecoration(String title, IconData icon) {
    return InputDecoration(
      labelText: title,
      prefixIcon: Icon(
        icon,
        color: const Color(0xff168A62),
      ),
      filled: true,
      fillColor: const Color(0xffF7F9FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffE5EAF1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xffE5EAF1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xff168A62), width: 1.4),
      ),
    );
  }

  Widget _customerNameField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
  }) {
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: (name) => name,
      optionsBuilder: (value) {
        final query = value.text.trim().toLowerCase();
        if (query.isEmpty) return const Iterable<String>.empty();
        return customerSuggestions.where(
          (name) => name.toLowerCase().contains(query),
        );
      },
      onSelected: (name) => controller.text = name,
      fieldViewBuilder: (context, textController, fieldFocusNode, onSubmitted) {
        return TextField(
          controller: textController,
          focusNode: fieldFocusNode,
          textCapitalization: TextCapitalization.words,
          decoration: fieldDecoration(label, Icons.person).copyWith(
            helperText: customerSuggestionsError != null
                ? 'Could not load suggestions: $customerSuggestionsError'
                : isLoadingCustomerSuggestions
                    ? 'Loading existing customer names...'
                    : 'Select a previous name or type a new one.',
            helperMaxLines: 2,
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        final matches = options.toList();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 5,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 220,
                maxWidth: 420,
              ),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 6),
                shrinkWrap: true,
                itemCount: matches.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 14, endIndent: 14),
                itemBuilder: (context, index) {
                  final name = matches[index];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xff168A62),
                    ),
                    title: Text(name),
                    onTap: () => onSelected(name),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void searchProducts(String value) {
    final query = value.trim().toLowerCase();

    setState(() {
      selectedProduct = null;
      rateController.clear();
      qtyController.clear();

      if (query.isEmpty) {
        filteredProducts = [];
        showProductSuggestions = false;
        return;
      }

      filteredProducts = products
          .where(
            (product) =>
                product.productName.trim().toLowerCase().contains(query) &&
                product.quantity > 0,
          )
          .toList();

      showProductSuggestions = true;
    });
  }

  //---------------- Add Item ----------------//
  void addItem() {
    // Product validation
    if (selectedProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a product first"),
        ),
      );
      return;
    }

    // Quantity validation
    if (qtyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter quantity"),
        ),
      );
      return;
    }

    final int? qty = int.tryParse(
      qtyController.text.trim(),
    );

    if (qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid quantity"),
        ),
      );
      return;
    }

    // Stock validation
    if (selectedProduct!.quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product is out of stock"),
        ),
      );
      return;
    }

    if (qty > selectedProduct!.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Only ${selectedProduct!.quantity} items available",
          ),
        ),
      );
      return;
    }

    final double rate = _toCurrency(selectedProduct!.price);

    billItems.add({
      "productId": selectedProduct!.id,
      "name": selectedProduct!.productName,
      "rate": rate,
      "qty": qty,
      "total": _toCurrency(rate * qty),
    });

    calculateTotal();

    setState(() {
      qtyController.clear();
      rateController.clear();
      productSearchController.clear();

      selectedProduct = null;
      filteredProducts.clear();
      showProductSuggestions = false;
    });
  } //---------------- Delete Item ----------------//

  void removeItem(int index) {
    billItems.removeAt(index);

    calculateTotal();

    setState(() {});
  }

  Future<void> scanBill() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(
                  Icons.camera_alt,
                  color: Colors.orange,
                ),
                title: const Text("Camera"),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.camera,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo,
                  color: Colors.orange,
                ),
                title: const Text("Gallery"),
                onTap: () {
                  Navigator.pop(
                    context,
                    ImageSource.gallery,
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (image == null) return;

      await processBill(image.path);
    } catch (e) {
      debugPrint("IMAGE PICK ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to select image: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> processBill(String path) async {
    try {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Scanning bill..."),
        ),
      );

      final inputImage = InputImage.fromFilePath(path);

      final textRecognizer = TextRecognizer();

      final result = await textRecognizer.processImage(
        inputImage,
      );

      await textRecognizer.close();

      if (!mounted) return;

      debugPrint("========== OCR TEXT ==========");
      debugPrint(result.text);
      debugPrint("================================");

      if (result.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Could not read text from bill"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      parseBill(result.text);
    } catch (e) {
      debugPrint("SCAN BILL ERROR: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to scan bill: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void parseBill(String text) {
    final List<Map<String, dynamic>> scannedItems = [];

    final lines = text
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      for (final product in products) {
        final productName = product.productName.trim().toLowerCase();

        final lowerLine = line.toLowerCase();

        if (!lowerLine.contains(productName)) {
          continue;
        }

        // ------------------------------------------------
        // Collect numbers from current line
        // ------------------------------------------------

        List<String> numbers = RegExp(
          r'\d+(?:\.\d+)?',
        ).allMatches(line).map((match) => match.group(0)!).toList();

        // ------------------------------------------------
        // Sometimes OCR puts product name and numbers
        // on separate lines.
        //
        // Example:
        //
        // Watch
        // 100
        // 2
        // ------------------------------------------------

        if (numbers.length < 2) {
          final extraText = <String>[];

          for (int j = i + 1; j < lines.length && j <= i + 2; j++) {
            extraText.add(lines[j]);
          }

          final combined = extraText.join(" ");

          numbers = RegExp(
            r'\d+(?:\.\d+)?',
          ).allMatches(combined).map((match) => match.group(0)!).toList();
        }

        if (numbers.isEmpty) {
          continue;
        }

        final parsed = _extractRateAndQuantity(
          numbers: numbers,
          product: product,
        );

        if (parsed == null) {
          continue;
        }

        final double rate = _toCurrency(parsed["rate"] as double);
        final int qty = parsed["qty"];

        // ------------------------------------------------
        // Stock validation
        // ------------------------------------------------

        if (qty <= 0) {
          continue;
        }

        if (qty > product.quantity) {
          debugPrint(
            "Scanned quantity $qty is greater than "
            "stock ${product.quantity} for ${product.productName}",
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${product.productName}: only "
                "${product.quantity} stock available",
              ),
              backgroundColor: Colors.orange,
            ),
          );

          continue;
        }

        scannedItems.add({
          "productId": product.id,
          "name": product.productName,
          "rate": rate,
          "qty": qty,
          "total": _toCurrency(rate * qty),
        });

        break;
      }
    }

    if (scannedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "No matching products found in scanned bill",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      billItems.clear();
      billItems.addAll(scannedItems);
    });

    calculateTotal();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "${scannedItems.length} item(s) added to Current Bill",
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Map<String, dynamic>? _extractRateAndQuantity({
    required List<String> numbers,
    required ProductModel product,
  }) {
    if (numbers.length < 2) {
      return null;
    }

    final values = numbers
        .map((value) => double.tryParse(value))
        .whereType<double>()
        .toList();

    if (values.length < 2) {
      return null;
    }

    // ------------------------------------------------
    // CASE 1
    //
    // Watch 100 2
    //
    // Rate = 100
    // Qty  = 2
    // ------------------------------------------------

    if (values.length == 2) {
      final first = values[0];
      final second = values[1];

      // If one number matches database price,
      // use that number as rate.
      if ((first - product.price).abs() < 0.01 && second > 0) {
        return {
          "rate": first,
          "qty": second.toInt(),
        };
      }

      if ((second - product.price).abs() < 0.01 && first > 0) {
        return {
          "rate": second,
          "qty": first.toInt(),
        };
      }

      // Default:
      // first = rate
      // second = quantity
      return {
        "rate": first,
        "qty": second.toInt(),
      };
    }

    // ------------------------------------------------
    // CASE 2
    //
    // Watch 100 2 200
    //
    // Rate = 100
    // Qty  = 2
    // Total = 200
    // ------------------------------------------------

    for (int i = 0; i < values.length; i++) {
      for (int j = 0; j < values.length; j++) {
        if (i == j) continue;

        final rate = values[i];
        final qty = values[j];

        if (qty <= 0) continue;

        if (qty != qty.toInt()) {
          continue;
        }

        final calculatedTotal = rate * qty;

        for (int k = 0; k < values.length; k++) {
          if (k == i || k == j) continue;

          final possibleTotal = values[k];

          if ((calculatedTotal - possibleTotal).abs() < 0.01) {
            return {
              "rate": rate,
              "qty": qty.toInt(),
            };
          }
        }
      }
    }

    // ------------------------------------------------
    // CASE 3
    //
    // If database price matches one number,
    // prefer that as rate.
    // ------------------------------------------------

    for (final value in values) {
      if ((value - product.price).abs() < 0.01) {
        final otherValues = values
            .where(
              (v) => (v - value).abs() >= 0.01,
            )
            .toList();

        if (otherValues.isNotEmpty) {
          final possibleQty = otherValues.first;

          if (possibleQty > 0 && possibleQty == possibleQty.toInt()) {
            return {
              "rate": value,
              "qty": possibleQty.toInt(),
            };
          }
        }
      }
    }

    // ------------------------------------------------
    // Final fallback
    // ------------------------------------------------

    final rate = values[0];
    final qty = values[1].toInt();

    if (qty <= 0) {
      return null;
    }

    return {
      "rate": rate,
      "qty": qty,
    };
  }
  //---------------- Total ----------------//

  void calculateTotal() {
    double total = 0;

    for (final item in billItems) {
      final itemTotal = double.tryParse(
            item["total"].toString(),
          ) ??
          0;

      total += _toCurrency(itemTotal);
    }

    final paid = double.tryParse(
          paidController.text.trim(),
        ) ??
        0;

    final newRemaining = _toCurrency(total - paid);

    setState(() {
      grandTotal = _toCurrency(total);
      remaining = newRemaining < 0 ? 0 : newRemaining;
    });
  }

  //---------------- Remaining ----------------//

  void calculateRemaining() {
    final paid = double.tryParse(
          paidController.text.trim(),
        ) ??
        0;

    final newRemaining = _toCurrency(grandTotal - paid);

    setState(() {
      remaining = newRemaining < 0 ? 0 : newRemaining;
    });
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: dueDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 20),
    );
    if (selected != null && mounted) {
      setState(() => dueDate = selected);
    }
  }

  void _showBillMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submitBill() async {
    if (isSubmittingBill) return;

    final sale = _retryBill;
    if (sale == null) {
      if (billItems.isEmpty) {
        _showBillMessage('Please add at least one product.');
        return;
      }
      if (selectedRegisteredUser == null) {
        _showBillMessage('Select a registered user before creating the bill.');
        return;
      }

      final customerName = customerController.text.trim();
      if (customerName.isEmpty) {
        _showBillMessage('Customer name is required.');
        return;
      }

      final total = _toCurrency(grandTotal);
      final paid = double.tryParse(paidController.text.trim());
      if (total <= 0) {
        _showBillMessage('Total amount must be greater than zero.');
        return;
      }
      if (paid == null || !paid.isFinite || paid < 0) {
        _showBillMessage('Enter a valid paid amount of zero or more.');
        return;
      }

      final paidAmount = _toCurrency(paid);
      if (paidAmount > total) {
        _showBillMessage('Paid amount cannot exceed the total amount.');
        return;
      }
      final udhariAmount = _toCurrency(total - paidAmount);
      if (udhariAmount > 0 && dueDate == null) {
        _showBillMessage('Select a due date for the pending Udhari amount.');
        return;
      }

      try {
        final itemSnapshot =
            billItems.map((item) => Map<String, dynamic>.from(item)).toList();
        _retryBill = CreateSaleModel(
          userId: selectedRegisteredUser!.id,
          idempotencyKey: CreateSaleModel.newIdempotencyKey(),
          totalAmount: total,
          paidAmount: paidAmount,
          udhariAmount: udhariAmount,
          dueDate: udhariAmount > 0 ? dueDate : null,
          paymentMode: paymentMode,
          customerName: customerName,
          items: itemSnapshot.map((item) {
            return SaleItemModel(
              productId: item['productId'] as int,
              rate: _toCurrency((item['rate'] as num).toDouble()),
              quantity: item['qty'] as int,
              amount: _toCurrency((item['total'] as num).toDouble()),
            );
          }).toList(),
        );
        _retryBillItems = itemSnapshot;
      } on ArgumentError catch (error) {
        _showBillMessage(error.message.toString());
        return;
      }
    }

    setState(() => isSubmittingBill = true);
    final submittedBill = _retryBill!;
    try {
      final response = await _salesService.createBill(
        submittedBill,
        widget.session,
      );
      if (!mounted) return;

      _retryBill = null;
      var completionMessage = response.billNo.isEmpty
          ? 'Bill saved successfully.'
          : 'Bill ${response.billNo} saved successfully.';
      try {
        final pdf = await PdfService.generateBill(
          items: _retryBillItems ?? billItems,
          total: submittedBill.totalAmount,
          paid: submittedBill.paidAmount,
          remaining: submittedBill.udhariAmount,
          paymentMode: submittedBill.paymentMode,
        );
        await Printing.layoutPdf(onLayout: (format) async => pdf);
      } catch (error) {
        completionMessage =
            '$completionMessage Print preview could not be opened: $error';
      }

      billItems.clear();
      _retryBillItems = null;
      grandTotal = 0;
      remaining = 0;
      selectedProduct = null;
      selectedRegisteredUser = null;
      dueDate = null;
      qtyController.clear();
      rateController.clear();
      paidController.clear();
      customerController.clear();
      productSearchController.clear();
      filteredProducts.clear();
      showProductSuggestions = false;
      setState(() {});
      _showBillMessage(completionMessage);
    } catch (error) {
      if (!mounted) return;
      _showBillMessage(error.toString());
    } finally {
      if (mounted) setState(() => isSubmittingBill = false);
    }
  }

  double _toCurrency(double amount) => (amount * 100).round() / 100;

  Widget _buildLeftPanel() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xffE8EDF4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Add products",
              style: TextStyle(
                color: Color(0xff172B4D),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Search your catalogue and add items to this bill.",
              style: TextStyle(
                color: Color(0xff75839A),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 17),
            if (isLoadingProducts)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(
                    color: Color(0xff168A62),
                  ),
                ),
              )
            else if (products.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xffFFF8EB),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xffF2D9A8)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      color: Color(0xffC27A12),
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'No products available',
                      style: TextStyle(
                        color: Color(0xff65430D),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Add a product before creating a bill.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xff8A6A39),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _openAddProduct,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Add product'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff168A62),
                        side: const BorderSide(color: Color(0xffB9DCCB)),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: loadProducts,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Refresh products'),
                    ),
                  ],
                ),
              )
            else
              TextField(
                controller: productSearchController,
                onChanged: searchProducts,
                decoration: fieldDecoration(
                  "Search Product *",
                  Icons.search,
                ).copyWith(
                  hintText: 'Type a product name to see matching products',
                ),
              ),
            if (showProductSuggestions)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xffE8EDF4),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08172B4D),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                constraints: const BoxConstraints(
                  maxHeight: 250,
                ),
                child: filteredProducts.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(15),
                        child: Text(
                          "No product found",
                          style: TextStyle(
                            color: Color(0xffC74646),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];

                          return ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.shopping_bag_outlined,
                              color: Color(0xff168A62),
                            ),
                            title: Text(
                              product.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              "₹${product.price.toStringAsFixed(2)} · "
                              "Stock: ${product.quantity}",
                              style: const TextStyle(
                                color: Color(0xff75839A),
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              final selected = product;

                              setState(() {
                                selectedProduct = selected;

                                filteredProducts.clear();
                                showProductSuggestions = false;

                                qtyController.clear();
                              });

                              productSearchController.text =
                                  selected.productName;
                              rateController.text =
                                  selected.price.toStringAsFixed(2);
                            },
                          );
                        },
                      ),
              ),
            const SizedBox(height: 15),
            TextField(
              controller: rateController,
              readOnly: true,
              keyboardType: TextInputType.number,
              decoration: fieldDecoration(
                "Rate",
                Icons.currency_rupee,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: qtyController,
              enabled: selectedProduct != null,
              keyboardType: TextInputType.number,
              decoration: fieldDecoration(
                selectedProduct != null
                    ? "Quantity *"
                    : products.isEmpty
                        ? "No Products Available"
                        : "Select Product First",
                Icons.numbers,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 51,
              child: ElevatedButton.icon(
                onPressed:
                    isLoadingProducts || products.isEmpty ? null : addItem,
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text(
                  "Add to bill",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff168A62),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightPanel() {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xffE8EDF4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                        "Current bill",
                        style: TextStyle(
                          color: Color(0xff172B4D),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Review items and complete payment",
                        style: TextStyle(
                          color: Color(0xff75839A),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xffE9F5F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${billItems.length} ${billItems.length == 1 ? 'item' : 'items'}",
                    style: const TextStyle(
                      color: Color(0xff168A62),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),

            // Bill List
            if (billItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 25,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffF7F9FC),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xffE8EDF4)),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 38,
                      color: Color(0xff98A2B3),
                    ),
                    SizedBox(height: 9),
                    Text(
                      "Your bill is empty",
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xff344054),
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Add products to start a new bill.",
                      style: TextStyle(
                        color: Color(0xff8995A8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: billItems.length,
                itemBuilder: (context, index) {
                  final item = billItems[index];
                  final itemTotal = (item["total"] as num).toDouble();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 9),
                    padding: const EdgeInsets.fromLTRB(12, 12, 6, 12),
                    decoration: BoxDecoration(
                      color: const Color(0xffFBFCFE),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xffE8EDF4)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xffE9F5F0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            color: Color(0xff168A62),
                            size: 19,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["name"].toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xff243344),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "₹${(item["rate"] as num).toStringAsFixed(2)} "
                                "× ${item["qty"]}",
                                style: const TextStyle(
                                  color: Color(0xff75839A),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "₹${itemTotal.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Color(0xff172B4D),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          tooltip: "Remove item",
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xff98A2B3),
                            size: 18,
                          ),
                          onPressed: () => removeItem(index),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xff173B35), Color(0xff168A62)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Grand Total",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    "₹${grandTotal.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 23,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              "Payment details",
              style: TextStyle(
                color: Color(0xff172B4D),
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<int>(
              initialValue: selectedRegisteredUser?.id,
              isExpanded: true,
              decoration: fieldDecoration(
                'Registered user *',
                Icons.verified_user_outlined,
              ),
              hint: Text(
                isLoadingRegisteredUsers
                    ? 'Loading registered users...'
                    : 'Select registered user',
              ),
              items: registeredUsers
                  .map(
                    (user) => DropdownMenuItem<int>(
                      value: user.id,
                      child: Text(
                        '${user.name} (${user.email})',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isSubmittingBill ||
                      isLoadingRegisteredUsers ||
                      _retryBill != null
                  ? null
                  : (userId) {
                      RegisteredUserModel? selectedUser;
                      for (final user in registeredUsers) {
                        if (user.id == userId) {
                          selectedUser = user;
                          break;
                        }
                      }
                      setState(() {
                        selectedRegisteredUser = selectedUser;
                      });
                    },
            ),
            if (registeredUsersError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        registeredUsersError!,
                        style: const TextStyle(
                          color: Color(0xffD64B4B),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed:
                          isLoadingRegisteredUsers ? null : loadRegisteredUsers,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),

            _customerNameField(
              controller: customerController,
              focusNode: customerFocusNode,
              label: 'Customer Name',
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              initialValue: paymentMode,
              decoration: fieldDecoration(
                "Payment Mode",
                Icons.payment,
              ),
              items: const [
                DropdownMenuItem(
                  value: "Cash",
                  child: Text("Cash"),
                ),
                DropdownMenuItem(
                  value: "UPI",
                  child: Text("UPI"),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  paymentMode = value!;
                });
              },
            ),

            const SizedBox(height: 12),

            TextField(
              controller: paidController,
              keyboardType: TextInputType.number,
              onChanged: (_) => calculateRemaining(),
              decoration: fieldDecoration(
                "Paid Amount",
                Icons.currency_rupee,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: remaining == 0
                    ? const Color(0xffE9F5F0)
                    : const Color(0xffFDEEEE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    remaining == 0
                        ? Icons.check_circle_rounded
                        : Icons.warning_rounded,
                    color: remaining == 0
                        ? const Color(0xff168A62)
                        : const Color(0xffD64B4B),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Remaining : ₹${remaining.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (_toCurrency(remaining) > 0) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: isSubmittingBill ? null : _selectDueDate,
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(
                  dueDate == null
                      ? 'Select due date *'
                      : 'Due date: ${dueDate!.day}/${dueDate!.month}/'
                          '${dueDate!.year}',
                ),
              ),
            ],

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: scanBill,
                icon: const Icon(Icons.document_scanner_outlined, size: 19),
                label: const Text(
                  "Scan bill",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFFF3E2),
                  foregroundColor: const Color(0xffB76B0B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            if (_retryBill != null)
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text(
                  'Retry sends the same bill and registered user as before.',
                  style: TextStyle(
                    color: Color(0xffB76B0B),
                    fontSize: 12,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 51,
              child: ElevatedButton.icon(
                onPressed: isSubmittingBill ? null : _submitBill,
                icon: const Icon(Icons.receipt_long_rounded, size: 19),
                label: isSubmittingBill
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _retryBill == null ? 'Complete sale' : 'Retry bill',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff168A62),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingIntro() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xff173B35), Color(0xff168A62)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x20168A62),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.point_of_sale_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create a sale",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Build a bill and record payment",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .13),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${billItems.length} ${billItems.length == 1 ? 'item' : 'items'}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
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
          "Billing",
          style: TextStyle(
            color: Color(0xff172B4D),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: "Add pending payment",
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xff168A62),
                side: const BorderSide(color: Color(0xffE8EDF4)),
              ),
              onPressed: () {
                pendingCustomerController.clear();
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: const Color(0xffFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 8),
                      contentPadding: const EdgeInsets.fromLTRB(22, 10, 22, 14),
                      title: const Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(0xffE9F5F0),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Color(0xff168A62),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            "Add pending amount",
                            style: TextStyle(
                              color: Color(0xff172B4D),
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      content: SizedBox(
                        width: 350,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _customerNameField(
                              controller: pendingCustomerController,
                              focusNode: pendingCustomerFocusNode,
                              label: 'Customer name *',
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: pendingAmountController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "Pending amount *",
                                prefixIcon: const Icon(
                                  Icons.currency_rupee,
                                  color: Color(0xff168A62),
                                ),
                                filled: true,
                                fillColor: const Color(0xffF7F9FC),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xffE5EAF1),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: Color(0xffE5EAF1),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.close),
                          label: const Text("Cancel"),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff168A62),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            // ==============================
                            // CUSTOMER NAME VALIDATION
                            // ==============================

                            if (pendingCustomerController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter customer name"),
                                ),
                              );
                              return;
                            }

                            // ==============================
                            // PENDING AMOUNT EMPTY VALIDATION
                            // ==============================

                            if (pendingAmountController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please enter pending amount"),
                                ),
                              );
                              return;
                            }

                            // ==============================
                            // PENDING AMOUNT VALIDATION
                            // ==============================

                            final double? pendingAmount = double.tryParse(
                              pendingAmountController.text.trim(),
                            );

                            if (pendingAmount == null || pendingAmount <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      "Please enter a valid pending amount"),
                                ),
                              );
                              return;
                            }

                            final success = await PendingService.addPending(
                              CreatePendingModel(
                                customerName:
                                    pendingCustomerController.text.trim(),
                                amount: pendingAmount,
                              ),
                            );

                            if (!mounted || !context.mounted) return;

                            // ==============================
                            // API FAILED
                            // ==============================

                            if (!success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Failed to Add Pending"),
                                ),
                              );
                              return;
                            }

                            _rememberCustomerName(
                              pendingCustomerController.text,
                            );

                            // ==============================
                            // SUCCESS
                            // ==============================

                            pendingCustomerController.clear();
                            pendingAmountController.clear();

                            Navigator.pop(context);

                            ScaffoldMessenger.of(this.context).showSnackBar(
                              const SnackBar(
                                content: Text("Pending Added Successfully"),
                              ),
                            );
                          },
                          icon: const Icon(Icons.save),
                          label: const Text("Save"),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(
                Icons.add_card_rounded,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 700;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 14 : 20,
              6,
              isMobile ? 14 : 20,
              16,
            ),
            child: isMobile
                ? SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildBillingIntro(),
                        const SizedBox(height: 14),
                        _buildLeftPanel(),
                        const SizedBox(height: 14),
                        _buildRightPanel(),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildBillingIntro(),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: SingleChildScrollView(
                                child: _buildLeftPanel(),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: SingleChildScrollView(
                                child: _buildRightPanel(),
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
    );
  }
}
