import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

class LeakDetectionScreen extends StatefulWidget {
  const LeakDetectionScreen({super.key});

  @override
  State<LeakDetectionScreen> createState() => _LeakDetectionScreenState();
}

class _LeakDetectionScreenState extends State<LeakDetectionScreen> {
  final _rand = Random();
  double _flowRate = 6.5; // L/min
  double _threshold = 20.0; // L/min
  int _durationMinutes = 10; // criteria window (demo)
  bool _valveOpen = true;
  bool _leakDetected = false;
  DateTime _lastUpdated = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      setState(() {
        _flowRate = (4 + _rand.nextDouble() * 10 + (_leakDetected ? 18 : 0)).clamp(0, 60);
        _lastUpdated = DateTime.now();
        // demo detection criteria
        _leakDetected = _flowRate > _threshold && _valveOpen;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leakage Detection & Control')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: _leakDetected ? Colors.red.withValues(alpha: 0.08) : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(_leakDetected ? Icons.warning_amber_rounded : Icons.shield_outlined, color: _leakDetected ? Colors.red : Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_leakDetected ? 'Potential water leakage detected' : 'No leakage detected', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 8),
                Text(_leakDetected
                    ? 'Abnormal flow meets configured criteria. Property owner notified immediately (demo). Consider shutting off supply.'
                    : 'Continuous flow-rate readings are compared against your configured threshold and detection criteria.'),
                const SizedBox(height: 12),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _metric(context, 'Current flow rate', '${_flowRate.toStringAsFixed(1)} L/min'),
                  _metric(context, 'Threshold', '${_threshold.toStringAsFixed(1)} L/min'),
                  _metric(context, 'Valve', _valveOpen ? 'OPEN' : 'CLOSED'),
                ]),
                const SizedBox(height: 8),
                Text('Last updated: ${formatDateTime(_lastUpdated)}', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Detection Configuration (Owner)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Flow-rate threshold: ${_threshold.toStringAsFixed(1)} L/min'),
                Slider(value: _threshold, min: 5, max: 50, divisions: 45, label: _threshold.toStringAsFixed(1), onChanged: (v) => setState(() => _threshold = v)),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Detection duration criteria'),
                  DropdownButton<int>(
                    value: _durationMinutes,
                    items: const [5, 10, 15, 30].map((m) => DropdownMenuItem(value: m, child: Text('$m min'))).toList(),
                    onChanged: (v) => setState(() => _durationMinutes = v ?? 10),
                  ),
                ]),
                Text('Potential leakage is flagged when abnormal flow conditions meet the configured threshold and duration (demo logic).', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Remote Water Supply Control', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Controls the household main supply via the connected solenoid valve (ESP32). Only authorized owners can control hardware. Commands require device confirmation before shown as successful.', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: _valveOpen ? _confirmShutOff : null,
                      icon: const Icon(Icons.block),
                      label: const Text('Turn OFF Supply'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: !_valveOpen ? _confirmTurnOn : null,
                      icon: const Icon(Icons.water_drop),
                      label: const Text('Turn ON Supply'),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Simulate abnormal flow (demo)'),
                  subtitle: const Text('Triggers leak-detected state for testing UI/alerts'),
                  value: _leakDetected && _flowRate > _threshold,
                  onChanged: (v) => setState(() { _leakDetected = v; if (v) _flowRate = _threshold + 10; }),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Alert History', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_leakDetected)
                  ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.error, color: Colors.red), title: const Text('Potential leakage detected'), subtitle: Text('Now • Flow ${_flowRate.toStringAsFixed(1)} L/min > ${_threshold.toStringAsFixed(1)} L/min')),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.check_circle, color: Colors.green), title: Text('Normal operation restored'), subtitle: Text('Today • Flow returned below threshold')),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.notifications_active_outlined), title: Text('Owner notified (leak alert example)'), subtitle: Text('Immediate notification sent to property owner')),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: Theme.of(context).textTheme.bodySmall), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
      );

  Future<void> _confirmShutOff() async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Shut off main water supply?'),
      content: const Text('This will send a command to close the main solenoid valve. Tenants may lose supply. Confirm to proceed.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Shut OFF'))],
    ));
    if (ok != true) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending OFF command to device...')));
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _valveOpen = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Device confirmed: main water supply is OFF.')));
  }

  Future<void> _confirmTurnOn() async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Turn water supply back ON?'),
      content: const Text('This will send a command to open the main solenoid valve. Confirm to proceed.'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Turn ON'))],
    ));
    if (ok != true) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sending ON command to device...')));
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _valveOpen = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Device confirmed: main water supply is ON.')));
  }
}
