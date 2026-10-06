import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/house.dart';
import '../models/tenant.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/rent_calculator.dart';
import '../widgets/status_dot.dart';

class TenantNotificationItem {
  final House house;
  final Tenant tenant;
  final RentInfo info;
  TenantNotificationItem(this.house, this.tenant, this.info);
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  Future<void> _sendTenantSms(BuildContext context, Tenant tenant, String phone) async {
    final message = 'Ndugu ${tenant.name} tunapenda kukukumbusha kwa heshima kuwa zimebaki siku 14 kufikia muda wa malipo ya kodi ya nyumba';
    final cleanedPhone = phone.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('sms:$cleanedPhone?body=${Uri.encodeComponent(message)}');
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!context.mounted) return;
      if (canLaunch) {
        await launchUrl(uri);
      } else {
        final waUri = Uri.parse('https://wa.me/$cleanedPhone?text=${Uri.encodeComponent(message)}');
        final canLaunchWa = await canLaunchUrl(waUri);
        if (!context.mounted) return;
        if (canLaunchWa) {
          await launchUrl(waUri, mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar(context, 'Could not launch messaging app for $phone');
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      _showSnackBar(context, 'Error launching message: $e');
    }
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final allItems = <TenantNotificationItem>[];
    for (final h in state.houses) {
      for (final t in h.tenants) {
        allItems.add(TenantNotificationItem(h, t, RentCalculator.compute(t)));
      }
    }

    final fourteenDayItems = allItems.where((i) => i.info.daysLeft == 14 || (i.info.daysLeft <= 14 && i.info.daysLeft >= 0 && !i.info.overdue)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenant Reminders'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tenants whose rent is 14 days (2 weeks) close to due. Tap to send separate notifications using their registered phone number.',
              style: TextStyle(color: AppColors.inkSoft, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: fourteenDayItems.isEmpty
                  ? const Center(
                      child: Text(
                        'No tenants currently have rent due in exactly 14 days or less (not overdue).\n(Showing all tenants below for your convenience)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.inkSoft),
                      ),
                    )
                  : ListView.separated(
                      itemCount: fourteenDayItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) => _buildTenantCard(context, fourteenDayItems[index]),
                    ),
            ),
            if (fourteenDayItems.isEmpty && allItems.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text('All Tenants (All due dates):', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: allItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => _buildTenantCard(context, allItems[index]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTenantCard(BuildContext context, TenantNotificationItem item) {
    final message = 'Ndugu ${item.tenant.name} tunapenda kukukumbusha kwa heshima kuwa zimebaki siku 14 kufikia muda wa malipo ya kodi ya nyumba';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.tenant.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
              StatusDot(overdue: item.info.overdue, size: 12),
              const SizedBox(width: 6),
              Text(
                item.info.overdue ? '${item.info.daysOverdue}d overdue' : '${item.info.daysLeft}d left',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: item.info.daysLeft == 14 ? Colors.blue[700] : AppColors.inkSoft,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('${item.house.location} · Rent: ${item.tenant.rent.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.inkSoft, fontSize: 12.5)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.sand.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Message: "$message"',
              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.ink),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text('Phone(s): ', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              Expanded(
                child: Text(
                  item.tenant.phones.isEmpty ? 'No phone number provided' : item.tenant.phones.join(', '),
                  style: const TextStyle(fontSize: 12, color: AppColors.inkSoft),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (item.tenant.phones.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: item.tenant.phones.map((phone) {
                return OutlinedButton.icon(
                  onPressed: () => _sendTenantSms(context, item.tenant, phone),
                  icon: const Icon(Icons.send, size: 14),
                  label: Text('Send to $phone'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                );
              }).toList(),
            )
          else
            const Text('Add phone number in tenant details to send notifications.', style: TextStyle(color: AppColors.red, fontSize: 11.5)),
        ],
      ),
    );
  }
}
