import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'notifications_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _changePassword(BuildContext context) {
    final state = context.read<AppState>();
    final userCtrl = TextEditingController(text: state.username);
    final passCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Username')),
            const SizedBox(height: 12),
            TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (userCtrl.text.trim().isEmpty || passCtrl.text.isEmpty) return;
              state.updateCredentials(userCtrl.text.trim(), passCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _row(
            context,
            'Signed in as',
            state.username,
            trailing: OutlinedButton(
              onPressed: () {
                state.logout();
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
              },
              child: const Text('Log out'),
            ),
          ),
          _row(
            context,
            'Change password',
            'Update your sign-in password for this session',
            trailing: OutlinedButton(onPressed: () => _changePassword(context), child: const Text('Change')),
          ),
          _row(
            context,
            'Push Notifications & Reminders',
            '14-day tenant reminders (using tenant phone numbers) & Admin push notification summary',
            trailing: OutlinedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              child: const Text('Open'),
            ),
          ),
          _row(context, 'Properties', '${state.totalHouses} houses managed'),
          _row(context, 'Tenants', '${state.totalTenants} tenants on record'),
          _row(context, 'Data storage', 'Data lives on this device only, in memory for this session'),
        ],
      ),
    );
  }

  Widget _row(BuildContext context, String title, String subtitle, {Widget? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.paper, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(4)),
      child: Row(children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: AppColors.inkSoft, fontSize: 12.5)),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ]),
    );
  }
}
