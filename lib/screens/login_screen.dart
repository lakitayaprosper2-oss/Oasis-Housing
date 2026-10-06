import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/sketch_icons.dart';
import 'dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String? _error;

  void _submit() {
    final state = context.read<AppState>();
    final ok = state.login(_userCtrl.text.trim(), _passCtrl.text);
    if (ok) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
    } else {
      setState(() => _error = 'Incorrect username or password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.paper,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const HouseSketchIcon(size: 46),
                  const SizedBox(height: 16),
                  Text(
                    'Oasis Housing',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sign in to manage your houses and tenants.',
                    style: TextStyle(color: AppColors.inkSoft, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  TextField(controller: _userCtrl, decoration: const InputDecoration(labelText: 'Username')),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    onSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _submit, child: const Text('Sign in'))),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(_error!, style: const TextStyle(color: AppColors.red, fontSize: 13)),
                    ),
                  const SizedBox(height: 18),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text(
                    'Demo access — username admin, password oasis2026. Data lives on this device only, in memory for this session.',
                    style: TextStyle(fontSize: 12, color: AppColors.inkSoft),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
