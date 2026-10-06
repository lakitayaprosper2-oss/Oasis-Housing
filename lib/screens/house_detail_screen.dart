import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/house.dart';
import '../models/tenant.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/rent_calculator.dart';
import '../widgets/status_dot.dart';
import '../widgets/tenant_form_dialog.dart';
import 'tenant_detail_screen.dart';

class HouseDetailScreen extends StatelessWidget {
  final String houseId;
  const HouseDetailScreen({super.key, required this.houseId});

  Future<void> _addTenant(BuildContext context) async {
    final tenant = await showTenantFormDialog(context);
    if (tenant != null && context.mounted) context.read<AppState>().addTenant(houseId, tenant);
  }

  Future<void> _editTenant(BuildContext context, Tenant t) async {
    final updated = await showTenantFormDialog(context, existing: t);
    if (updated != null && context.mounted) context.read<AppState>().updateTenant(houseId, updated);
  }

  void _confirmDelete(BuildContext context, Tenant t) {
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
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, Tenant t) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(ctx);
              _editTenant(context, t);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.red),
            title: const Text('Delete', style: TextStyle(color: AppColors.red)),
            onTap: () {
              Navigator.pop(ctx);
              _confirmDelete(context, t);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final house = state.houses.firstWhere((h) => h.id == houseId, orElse: () => House(id: '', location: ''));
    if (house.id.isEmpty) return const Scaffold(body: Center(child: Text('House not found')));

    return Scaffold(
      appBar: AppBar(
        title: Text(house.location, overflow: TextOverflow.ellipsis),
        actions: [
          TextButton(onPressed: () => _addTenant(context), child: const Text('+ New')),
          const SizedBox(width: 8),
        ],
      ),
      body: house.tenants.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No tenants yet. Add one with the + New button above.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.inkSoft),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: house.tenants.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final t = house.tenants[i];
                final info = RentCalculator.compute(t);
                return ListTile(
                  tileColor: AppColors.paper,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TenantDetailScreen(houseId: houseId, tenantId: t.id)),
                  ),
                  onLongPress: () => _showOptions(context, t),
                  leading: StatusDot(overdue: info.overdue, size: 12),
                  title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${t.phones.join(', ')}\n'
                    'Next: ${DateFormat('dd MMM').format(info.nextDate)} · '
                    '${info.overdue ? '${info.daysOverdue}d overdue' : '${info.daysLeft}d left'}'
                    '${info.amountRemaining > 0 ? ' · Owes ${info.amountRemaining.toStringAsFixed(0)}' : ''}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _showOptions(context, t)),
                );
              },
            ),
    );
  }
}
