import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/session.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  UserRole _role = UserRole.owner;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 700));
    SessionStore.instance.login(asRole: _role, name: _name.text.trim().isEmpty ? (_role == UserRole.owner ? 'Property Owner' : 'Tenant') : _name.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    context.go(_role == UserRole.owner ? AppRoutes.owner : AppRoutes.renter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                SegmentedButton<UserRole>(
                  segments: const [
                    ButtonSegment(value: UserRole.owner, label: Text('Owner')),
                    ButtonSegment(value: UserRole.renter, label: Text('Tenant')),
                  ],
                  selected: {_role},
                  onSelectionChanged: (s) => setState(() => _role = s.first),
                ),
                const SizedBox(height: 16),
                TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 12),
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 12),
                TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone number', prefixIcon: Icon(Icons.phone_outlined))),
                const SizedBox(height: 12),
                TextField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline))),
                const SizedBox(height: 20),
                FilledButton(onPressed: _loading ? null : _register, child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Register')),
                const SizedBox(height: 8),
                TextButton(onPressed: () => context.go(AppRoutes.login), child: const Text('Already have an account? Login')),
                const SizedBox(height: 8),
                Text('Accounts are role-based (Owner/Tenant) and linked to a property in production. This demo uses local mock session.', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
