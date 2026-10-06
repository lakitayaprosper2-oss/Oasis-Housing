import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/house.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/house_form_dialog.dart';
import 'house_detail_screen.dart';

class HousesScreen extends StatelessWidget {
  const HousesScreen({super.key});

  Future<void> _addHouse(BuildContext context) async {
    final result = await showHouseFormDialog(context);
    if (result != null && context.mounted) context.read<AppState>().addHouse(result.location);
  }

  Future<void> _editHouse(BuildContext context, House h) async {
    final result = await showHouseFormDialog(context, initialLocation: h.location);
    if (result != null && context.mounted) context.read<AppState>().updateHouse(h.id, result.location);
  }

  void _confirmDelete(BuildContext context, House h) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete house?'),
        content: Text('Delete "${h.location}" and all its tenants? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<AppState>().deleteHouse(h.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  // Long-press (mobile) or the ⋮ button (desktop/double-click feel) both open this.
  void _showOptions(BuildContext context, House h) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit'),
            onTap: () {
              Navigator.pop(ctx);
              _editHouse(context, h);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.red),
            title: const Text('Delete', style: TextStyle(color: AppColors.red)),
            onTap: () {
              Navigator.pop(ctx);
              _confirmDelete(context, h);
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final houses = context.watch<AppState>().houses;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Houses'),
        actions: [
          TextButton(onPressed: () => _addHouse(context), child: const Text('+ New')),
          const SizedBox(width: 8),
        ],
      ),
      body: houses.isEmpty
          ? const _Empty()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: houses.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final h = houses[i];
                return ListTile(
                  tileColor: AppColors.paper,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HouseDetailScreen(houseId: h.id))),
                  onLongPress: () => _showOptions(context, h),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.sandDeep,
                    foregroundColor: AppColors.ink,
                    child: Text('${i + 1}'),
                  ),
                  title: Text(h.location, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${h.tenants.length} ${h.tenants.length == 1 ? 'tenant' : 'tenants'}'),
                  trailing: IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _showOptions(context, h)),
                );
              },
            ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.home_outlined, size: 48, color: AppColors.inkSoft),
            SizedBox(height: 12),
            Text('No houses yet', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text(
              'Add your first property with the + New button above.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
