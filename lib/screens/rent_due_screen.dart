import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/house.dart';
import '../models/tenant.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/rent_calculator.dart';
import '../widgets/status_dot.dart';
import 'tenant_detail_screen.dart';

class _Row {
  final House house;
  final Tenant tenant;
  final RentInfo info;
  _Row(this.house, this.tenant, this.info);
}

class RentDueScreen extends StatelessWidget {
  const RentDueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final rows = <_Row>[];
    for (final h in state.houses) {
      for (final t in h.tenants) {
        rows.add(_Row(h, t, RentCalculator.compute(t)));
      }
    }
    rows.sort((a, b) {
      if (a.info.overdue != b.info.overdue) return a.info.overdue ? -1 : 1;
      if (a.info.overdue) return b.info.daysOverdue.compareTo(a.info.daysOverdue);
      return a.info.daysLeft.compareTo(b.info.daysLeft);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Rent Due')),
      body: rows.isEmpty
          ? const Center(child: Text('No tenants yet.', style: TextStyle(color: AppColors.inkSoft)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rows.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final row = rows[i];
                return ListTile(
                  tileColor: AppColors.paper,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TenantDetailScreen(houseId: row.house.id, tenantId: row.tenant.id)),
                  ),
                  leading: StatusDot(overdue: row.info.overdue, size: 12),
                  title: Text(row.tenant.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${row.house.location}\n'
                    'Next: ${DateFormat('dd MMM').format(row.info.nextDate)} · '
                    '${row.info.overdue ? '${row.info.daysOverdue}d overdue' : '${row.info.daysLeft}d left'}'
                    '${row.info.amountRemaining > 0 ? ' · Owes ${row.info.amountRemaining.toStringAsFixed(0)}' : ''}',
                  ),
                  isThreeLine: true,
                );
              },
            ),
    );
  }
}
