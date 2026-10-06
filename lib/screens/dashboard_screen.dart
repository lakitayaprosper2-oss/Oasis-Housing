import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/sketch_icons.dart';
import 'houses_screen.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';
import 'rent_due_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oasis Housing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Log out',
            onPressed: () {
              state.logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good day.', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            const Text("Here's an overview of your properties.", style: TextStyle(color: AppColors.inkSoft)),
            const SizedBox(height: 20),
            LayoutBuilder(builder: (context, constraints) {
              final cross = constraints.maxWidth > 620 ? 3 : (constraints.maxWidth > 380 ? 2 : 1);
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cross,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
                children: [
                  _Tile(
                    icon: const HouseSketchIcon(size: 56),
                    label: 'House',
                    sub: '${state.totalHouses} ${state.totalHouses == 1 ? 'property' : 'properties'}',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HousesScreen())),
                  ),
                  _Tile(
                    icon: const MoneySketchIcon(size: 56),
                    label: 'Rent Due',
                    sub: '${state.overdueCount} pending',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RentDueScreen())),
                  ),
                  _Tile(
                    icon: const Icon(Icons.notifications_active, size: 48, color: AppColors.clay),
                    label: 'Notifications',
                    sub: 'Reminders & Admin',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                  ),
                  _Tile(
                    icon: const SettingsSketchIcon(size: 56),
                    label: 'Settings',
                    sub: 'Account & app',
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final Widget icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.label, required this.sub, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.paper,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(height: 14),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 4),
            Text(sub, style: const TextStyle(color: AppColors.inkSoft, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
