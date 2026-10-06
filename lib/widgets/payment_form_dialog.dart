import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';

class PaymentFormResult {
  final String date;
  final double amount;
  final String? receiptPath;
  final String? receiptName;
  PaymentFormResult({required this.date, required this.amount, this.receiptPath, this.receiptName});
}

class PaymentFormDialog extends StatefulWidget {
  final double rentAmount;
  final double alreadyPaid;
  final double owed;
  const PaymentFormDialog({super.key, required this.rentAmount, required this.alreadyPaid, required this.owed});

  @override
  State<PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<PaymentFormDialog> {
  DateTime _date = DateTime.now();
  final _amountCtrl = TextEditingController();
  String? _receiptPath;
  String? _receiptName;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2015),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickReceipt() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _receiptPath = result.files.single.path;
        _receiptName = result.files.single.name;
      });
    }
  }

  void _save() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount.')),
      );
      return;
    }
    Navigator.pop(
      context,
      PaymentFormResult(
        date: DateFormat('yyyy-MM-dd').format(_date),
        amount: amount,
        receiptPath: _receiptPath,
        receiptName: _receiptName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add payment'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rent for this cycle: ${widget.rentAmount.toStringAsFixed(0)}\n'
              'Already paid: ${widget.alreadyPaid.toStringAsFixed(0)}\n'
              'Still owed: ${widget.owed.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 12.5, color: AppColors.inkSoft),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date of payment'),
                child: Text(DateFormat('dd MMM yyyy').format(_date)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount paid'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickReceipt,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(children: [
                  const Icon(Icons.upload_file, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _receiptName ?? 'Upload receipt (document or image)',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: const Text('Save payment')),
      ],
    );
  }
}

Future<PaymentFormResult?> showPaymentFormDialog(
  BuildContext context, {
  required double rentAmount,
  required double alreadyPaid,
  required double owed,
}) {
  return showDialog<PaymentFormResult>(
    context: context,
    builder: (_) => PaymentFormDialog(rentAmount: rentAmount, alreadyPaid: alreadyPaid, owed: owed),
  );
}
