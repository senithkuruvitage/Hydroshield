import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

class CleaningScreen extends StatefulWidget {
  const CleaningScreen({super.key});

  @override
  State<CleaningScreen> createState() => _CleaningScreenState();
}

class _CleaningScreenState extends State<CleaningScreen> {
  String _status = 'OFF'; // ON / OFF / Cleaning
  DateTime _lastCleaned = DateTime(2026, 10, 20);
  bool _running = false;

  @override
  Widget build(BuildContext context) {
    final daysSince = DateTime.now().difference(_lastCleaned).inDays;
    final recommended = daysSince >= 30;
    return Scaffold(
      appBar: AppBar(title: const Text('Tank Cleaning & Maintenance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Maintenance Status', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListTile(contentPadding: EdgeInsets.zero, leading: Icon(recommended ? Icons.warning_amber : Icons.check_circle, color: recommended ? Colors.orange : Colors.green), title: Text(recommended ? 'Tank cleaning recommended' : 'Maintenance on track'), subtitle: Text('Estimated maintenance recommendation based on available sensor data and configured intervals (not a direct dirt measurement).')),
                _row('Estimated sediment/maintenance indicator', recommended ? 'High (estimate)' : 'Moderate (estimate)'),
                _row('Days since last cleaning', '$daysSince days'),
                _row('Last cleaning date', formatDate(_lastCleaned)),
                _row('Current cleaning system status', _status),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Manual Cleaning Control (Owner)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Authorized property owners can activate the tank cleaning mechanism. You will be asked to confirm before activation.', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _running ? null : _confirmStartCleaning,
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Activate Cleaning'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _status == 'OFF' ? null : () => setState(() => _status = 'OFF'),
                      icon: const Icon(Icons.power_settings_new),
                      label: const Text('Set OFF'),
                    ),
                  ),
                ]),
                if (_running) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text('Cleaning in progress... status will update when mechanism reports completion (demo).'),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Maintenance History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.check_circle, color: Colors.green), title: Text('Completed • ${formatDate(DateTime(2026, 10, 20))}'), subtitle: const Text('Manual activation by owner')),
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.check_circle, color: Colors.green), title: Text('Completed • ${formatDate(DateTime(2026, 9, 15))}'), subtitle: const Text('Scheduled maintenance')),
                ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.info_outline), title: Text('Recommended • ${formatDate(DateTime(2026, 8, 30))}'), subtitle: const Text('Notification sent to owner')),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmStartCleaning() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Activate tank cleaning?'),
        content: const Text('This will send a command to activate the tank cleaning mechanism. Confirm to proceed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm & Activate')),
        ],
      ),
    );
    if (ok != true) return;
    setState(() {
      _status = 'Cleaning';
      _running = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cleaning command sent (demo). Waiting for device confirmation...')));
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _status = 'ON';
      _running = false;
      _lastCleaned = DateTime.now();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tank cleaning completed (simulated).')));
  }

  Widget _row(String a, String b) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(a)), const SizedBox(width: 8), Text(b, style: const TextStyle(fontWeight: FontWeight.w600))]),
      );
}
