import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HydroShieldApp());
}

class HydroShieldApp extends StatefulWidget {
  const HydroShieldApp({super.key});

  @override
  State<HydroShieldApp> createState() => _HydroShieldAppState();
}

class _HydroShieldAppState extends State<HydroShieldApp> {
  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HydroShield',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
    );
  }
}
