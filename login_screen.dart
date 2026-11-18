import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.owner;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    SessionStore.instance.login(asRole: _role, name: _role == UserRole.owner ? 'Property Owner' : 'Tenant');
    if (!mounted) return;
    setState(() => _loading = false);
    context.go(_role == UserRole.owner ? AppRoutes.owner : AppRoutes.renter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.water_drop, size: 72, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 12),
                  Text('HydroShield', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Smart Water Management', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 32),
                  SegmentedButton<UserRole>(
                    segments: const [
                      ButtonSegment(value: UserRole.owner, label: Text('Owner'), icon: Icon(Icons.admin_panel_settings)),
                      ButtonSegment(value: UserRole.renter, label: Text('Tenant'), icon: Icon(Icons.person)),
                    ],
                    selected: {_role},
                    onSelectionChanged: (s) => setState(() => _role = s.first),
                  ),
                  const SizedBox(height: 16),
                  TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                  const SizedBox(height: 12),
                  TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _loading ? null : _login,
                    child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Login'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(onPressed: () => context.go(AppRoutes.register), child: const Text('Create account')),
                  const SizedBox(height: 8),
                  Text('Demo: select a role and tap Login to enter the ${_role == UserRole.owner ? "Owner" : "Tenant"} dashboard.', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
