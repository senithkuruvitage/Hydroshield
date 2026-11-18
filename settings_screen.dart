import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/session.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _bank = TextEditingController(text: 'Hydro Bank');
  final _account = TextEditingController(text: '1234 5678 9012');
  final _other = TextEditingController(text: 'Cash / Bank transfer accepted');
  int _tenants = 4;
  bool _lowLevelAlerts = true;
  bool _leakAlerts = true;
  bool _billAlerts = true;

  @override
  void dispose() {
    _bank.dispose();
    _account.dispose();
    _other.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = SessionStore.instance;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Management')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Property & Account', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.home_work_outlined), title: Text(session.propertyName.value ?? 'Property'), subtitle: const Text('Owner-managed property • data kept separate per property (design)')),
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.person_outline), title: Text(session.userName.value ?? 'Owner'), subtitle: const Text('Role: Property Owner')),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Tenant Management', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Number of tenants residing'),
                  subtitle: Text('$_tenants tenants configured (each tenant has individual account in production)'),
                  trailing: IconButton(icon: const Icon(Icons.edit), onPressed: _editTenants),
                ),
                const Text('Tenants can access only information relevant to their assigned property and consumption records. Role-based permissions enforced.', style: TextStyle(fontSize: 12)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Payment Information (Owner)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(controller: _bank, decoration: const InputDecoration(labelText: 'Bank name')),
                const SizedBox(height: 8),
                TextField(controller: _account, decoration: const InputDecoration(labelText: 'Account details')),
                const SizedBox(height: 8),
                TextField(controller: _other, decoration: const InputDecoration(labelText: 'Other accepted payment methods')),
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerRight, child: FilledButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment details saved (demo).'))), child: const Text('Save payment info'))),
                const SizedBox(height: 4),
                const Text('Displayed to tenants. Online payment gateway integration available when configured. Sensitive data should be protected in production.', style: TextStyle(fontSize: 12)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Notifications & Alerts', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Low water level alerts'), value: _lowLevelAlerts, onChanged: (v) => setState(() => _lowLevelAlerts = v)),
                SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Leakage / abnormal flow alerts'), value: _leakAlerts, onChanged: (v) => setState(() => _leakAlerts = v)),
                SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Billing & payment alerts'), value: _billAlerts, onChanged: (v) => setState(() => _billAlerts = v)),
                const Text('Events: leakage, unusual consumption, low level, cleaning recommended/completed, supply ON/OFF, bill generated, payment received/pending. Delivered by role.', style: TextStyle(fontSize: 12)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('System & Integration (Design)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.memory), title: Text('ESP32 hardware'), subtitle: Text('Ultrasonic level, flow sensor, solenoid valve, cleaning mechanism. Commands confirmed by device before success.')),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.cloud_outlined), title: Text('Backend & sync'), subtitle: Text('Mock/demo mode now. Designed for backend sync, offline handling, last-updated timestamps, and secure per-property data.')),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.security), title: Text('Security'), subtitle: Text('Role-based access; only authorized users control hardware; tenants cannot modify prices/thresholds/payment details.')),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () {
              SessionStore.instance.logout();
              context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _editTenants() async {
    final c = TextEditingController(text: _tenants.toString());
    final v = await showDialog<int>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Configure number of tenants'),
      content: TextField(controller: c, keyboardType: TextInputType.number),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, int.tryParse(c.text)), child: const Text('Save'))],
    ));
    if (v != null && v > 0) setState(() => _tenants = v);
  }
}
