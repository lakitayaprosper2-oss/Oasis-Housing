import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/house.dart';
import '../models/tenant.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/rent_calculator.dart';
import '../widgets/payment_form_dialog.dart';
import '../widgets/status_dot.dart';
import '../widgets/tenant_form_dialog.dart';

class TenantDetailScreen extends StatelessWidget {
  final String houseId;
  final String tenantId;
  const TenantDetailScreen({super.key, required this.houseId, required this.tenantId});

  Future<void> _addPayment(BuildContext context, Tenant t) async {
    final info = RentCalculator.compute(t);
    final result = await showPaymentFormDialog(
      context,
      rentAmount: t.rent,
      alreadyPaid: info.amountPaid,
      owed: info.amountRemaining,
    );
    if (result != null && context.mounted) {
      context.read<AppState>().addPayment(
            houseId,
            tenantId,
            date: result.date,
            amount: result.amount,
            receiptPath: result.receiptPath,
            receiptName: result.receiptName,
          );
    }
  }

  Future<void> _edit(BuildContext context, Tenant t) async {
    final updated = await showTenantFormDialog(context, existing: t);
    if (updated != null && context.mounted) context.read<AppState>().updateTenant(houseId, updated);
  }

  void _delete(BuildContext context, Tenant t) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete tenant?'),
        content: Text('Delete "${t.name}"? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteTenant(houseId, t.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final house = state.houses.firstWhere((h) => h.id == houseId, orElse: () => House(id: '', location: ''));
    if (house.id.isEmpty) return const Scaffold(body: Center(child: Text('Not found')));
    final tenant = house.tenants.firstWhere(
      (t) => t.id == tenantId,
      orElse: () => Tenant(id: '', name: '', phones: const [], rent: 0, intervalMonths: 1, startDate: '2020-01-01'),
    );
    if (tenant.id.isEmpty) return const Scaffold(body: Center(child: Text('Tenant not found')));

    final info = RentCalculator.compute(tenant);

    return Scaffold(
      appBar: AppBar(title: Text(tenant.name, overflow: TextOverflow.ellipsis)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(children: [
            Expanded(child: Text(house.location, style: const TextStyle(color: AppColors.inkSoft))),
            StatusDot(overdue: info.overdue, size: 14),
          ]),
          const SizedBox(height: 18),
          _grid(context, [
            _item('Phone number(s)', tenant.phones.join('\n')),
            _item('Gender / Age', '${tenant.gender.isEmpty ? '—' : tenant.gender}${tenant.age != null ? ', ${tenant.age}' : ''}'),
            _item('Tribe', tenant.tribe.isEmpty ? '—' : tenant.tribe),
            _item('Rent amount', '${tenant.rent.toStringAsFixed(0)} / ${tenant.intervalMonths} month(s)'),
            _item('Rent start date', DateFormat('dd MMM yyyy').format(DateTime.parse(tenant.startDate))),
            _item('Payment interval', 'Every ${tenant.intervalMonths} month(s)'),
            _item('Date of next rent', DateFormat('dd MMM yyyy').format(info.nextDate)),
            _item('Days left till next rent', '${info.daysLeft} day(s)'),
            _item('Days rent overdue', info.overdue ? '${info.daysOverdue} day(s) overdue' : 'Not overdue'),
            _item('Amount paid (this cycle)', info.amountPaid.toStringAsFixed(0)),
            _item('Amount remaining', info.amountRemaining > 0 ? info.amountRemaining.toStringAsFixed(0) : 'Fully paid'),
          ]),
          const SizedBox(height: 20),
          const Text('Rent contract',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.inkSoft, letterSpacing: 0.4)),
          const SizedBox(height: 6),
          Text(tenant.docName ?? 'No document uploaded.'),
          const SizedBox(height: 20),
          const Text('Payment history',
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.inkSoft, letterSpacing: 0.4)),
          const SizedBox(height: 6),
          if (tenant.payments.isEmpty)
            const Text('No payments recorded yet.', style: TextStyle(color: AppColors.inkSoft))
          else
            ...tenant.payments.reversed.map((p) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(4)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${DateFormat('dd MMM yyyy').format(DateTime.parse(p.date))} — paid ${p.amount.toStringAsFixed(0)}'),
                            Text(
                              p.remaining > 0 ? 'Remaining after: ${p.remaining.toStringAsFixed(0)}' : 'Cycle settled in full',
                              style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                            ),
                          ],
                        ),
                      ),
                      if (p.receiptName != null) const Icon(Icons.receipt_long, color: AppColors.inkSoft),
                    ],
                  ),
                )),
          const SizedBox(height: 24),
          Wrap(spacing: 10, runSpacing: 10, children: [
            ElevatedButton(onPressed: () => _addPayment(context, tenant), child: const Text('+ Add payment')),
            OutlinedButton(onPressed: () => _edit(context, tenant), child: const Text('Edit tenant')),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.red, side: const BorderSide(color: AppColors.red)),
              onPressed: () => _delete(context, tenant),
              child: const Text('Delete tenant'),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _grid(BuildContext context, List<Widget> items) {
    return LayoutBuilder(builder: (context, constraints) {
      final cross = constraints.maxWidth > 480 ? 2 : 1;
      return GridView.count(
        crossAxisCount: cross,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 18,
        childAspectRatio: 3.6,
        children: items,
      );
    });
  }

  Widget _item(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.inkSoft, letterSpacing: 0.4)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14.5)),
      ],
    );
  }
}
