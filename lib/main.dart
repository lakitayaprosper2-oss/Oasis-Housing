import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  NotificationService.instance.init(navigatorKey);
  runApp(const OasisHousingApp());
}

class OasisHousingApp extends StatelessWidget {
  const OasisHousingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'Oasis Housing',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        navigatorKey: navigatorKey,
        home: const _Startup(),
      ),
    );
  }
}

/// Loads saved houses/tenants from Firestore before showing the login screen,
/// so all devices sync in real time.
class _Startup extends StatefulWidget {
  const _Startup();

  @override
  State<_Startup> createState() => _StartupState();
}

class _StartupState extends State<_Startup> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.isLoaded) {
      return const Scaffold(
        backgroundColor: AppColors.sand,
        body: Center(child: CircularProgressIndicator(color: AppColors.clay)),
      );
    }
    return const LoginScreen();
  }
}
