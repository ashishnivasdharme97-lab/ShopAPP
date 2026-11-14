import 'package:flutter/material.dart';
import 'package:shop_app/models/auth_session.dart';
import 'package:shop_app/models/udhar_model.dart';
import 'package:shop_app/services/udhar_service.dart';

class CreateUdharScreen extends StatefulWidget {
  const CreateUdharScreen({
    super.key,
    required this.session,
    required this.userId,
    this.service,
  });

  final AuthSession session;
  final int userId;
  final UdharService? service;

  @override
  State<CreateUdharScreen> createState() => _CreateUdharScreenState();
}

class _CreateUdharScreenState extends State<CreateUdharScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerController = TextEditingController();
  final _amountController = TextEditingController();
  final _paidController = TextEditingController(text: '0');
  final _notesController = TextEditingController();

  DateTime? _dueDate;
  bool _isSaving = false;
  late final UdharService _service;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? UdharService();
  }

  @override
  void dispose() {
    if (widget.service == null) _service.close();
    _customerController.dispose();
    _amountController.dispose();
    _paidController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDueDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 20),
    );
    if (selectedDate != null) setState(() => _dueDate = selectedDate);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date.')),
      );
      return;
    }

    final amount = double.parse(_amountController.text.trim());
    final paidAmount = double.parse(_paidController.text.trim());
    final remainingAmount =
        double.parse((amount - paidAmount).toStringAsFixed(2));
    final entry = UdharModel(
      userId: widget.userId,
      customerName: _customerController.text.trim(),
      amount: amount,
      remainingAmount: remainingAmount,
      dueDate: DateTime.utc(_dueDate!.year, _dueDate!.month, _dueDate!.day),
      notes: _notesController.text.trim(),
      isPaid: remainingAmount == 0,
      paidAmount: paidAmount,
    );

    setState(() => _isSaving = true);
    try {
      final created = await _service.create(entry, widget.session);
      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Udhar')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextFormField(
              controller: _customerController,
              decoration: const InputDecoration(
                labelText: 'Customer name',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Customer name is required.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Total amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final amount = double.tryParse(value?.trim() ?? '');
                if (amount == null || amount <= 0) {
                  return 'Enter an amount greater than 0.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _paidController,
              decoration: const InputDecoration(
                labelText: 'Amount paid',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                final paid = double.tryParse(value?.trim() ?? '');
                final amount = double.tryParse(_amountController.text.trim());
                if (paid == null || paid < 0) {
                  return 'Enter a valid paid amount.';
                }
                if (amount != null && paid > amount) {
                  return 'Paid amount cannot exceed total amount.';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _isSaving ? null : _selectDueDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                _dueDate == null
                    ? 'Select due date'
                    : 'Due date: ${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}',
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 1000,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save Udhar'),
            ),
          ],
        ),
      ),
    );
  }
}
