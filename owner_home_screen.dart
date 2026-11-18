import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/session.dart';
import '../../core/utils/formatters.dart';
import 'animated_water_tank.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  final _rand = Random();
  double _level = 0.72;
  bool _isFilling = false;
  bool _isDraining = false;
  bool _offline = false;
  DateTime _lastUpdated = DateTime.now();
  Timer? _timer;

  TankState get _state {
    final p = _level * 100;
    if (p >= 75) return TankState.full;
    if (p >= 25) return TankState.normal;
    if (p >= 10) return TankState.low;
    return TankState.critical;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _offline) return;
      setState(() {
        final delta = (_rand.nextDouble() - 0.5) * 0.06;
        _level = (_level + delta).clamp(0.0, 1.0);
        _isFilling = delta > 0.015;
        _isDraining = delta < -0.015;
        _lastUpdated = DateTime.now();
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
    final session = SessionStore.instance;
    final liters = _level * TankCapacity.typical;
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Owner Dashboard'),
          Text(session.propertyName.value ?? 'Property', style: Theme.of(context).textTheme.bodySmall),
        ]),
        actions: [
          IconButton(
            tooltip: _offline ? 'Mark online' : 'Simulate offline',
            onPressed: () => setState(() => _offline = !_offline),
            icon: Icon(_offline ? Icons.cloud_off : Icons.cloud_done),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => _showNotifications(context),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => setState(() => _lastUpdated = DateTime.now()),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  Row(children: [
                    Expanded(child: Text('Water Tank Monitoring', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                    Chip(label: Text(_offline ? 'Offline' : 'Online'), avatar: Icon(_offline ? Icons.wifi_off : Icons.wifi, size: 16)),
                  ]),
                  const SizedBox(height: 8),
                  Center(child: AnimatedWaterTank(level: _level, state: _state, isFilling: _isFilling && !_offline, isDraining: _isDraining && !_offline, isOffline: _offline, size: 230)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _InfoPill(icon: Icons.percent, label: 'Level', value: formatPercent(_level)),
                    _InfoPill(icon: Icons.water, label: 'Remaining', value: formatLiters(liters)),
                    _InfoPill(icon: Icons.speed, label: 'Flow', value: '${(4 + _rand.nextDouble() * 8).toStringAsFixed(1)} L/min'),
                  ]),
                  const SizedBox(height: 8),
                  Text('Last updated: ${formatDateTime(_lastUpdated)}${_offline ? ' (cached)' : ''}', style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Water Consumption Overview', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Row(children: [
                    Expanded(child: _StatTile(title: 'Today', value: '420 L', subtitle: 'Property total')),
                    SizedBox(width: 8),
                    Expanded(child: _StatTile(title: 'This Week', value: '2,980 L', subtitle: 'All tenants')),
                    SizedBox(width: 8),
                    Expanded(child: _StatTile(title: 'This Month', value: '11.6 m³', subtitle: 'Estimated')),
                  ]),
                  const SizedBox(height: 8),
                  Text('Tenants configured: 4 • Individual/allocation records shown in Usage & Billing.', style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Quick Status', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.shield_moon_outlined, color: Colors.teal), title: Text('Leakage monitoring'), subtitle: Text('No abnormal flow detected. Threshold configurable in Alerts.')),
                  const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.cleaning_services_outlined, color: Colors.blue), title: Text('Tank cleaning'), subtitle: Text('Estimated maintenance recommended in 12 days. Last cleaned: Oct 20, 2026.')),
                  const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.payments_outlined, color: Colors.green), title: Text('Billing & payments'), subtitle: Text('2 pending tenant payments. Manage in Usage & Billing / Settings.')),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text('Notifications & Alerts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          ListTile(leading: Icon(Icons.warning_amber, color: Colors.orange), title: Text('Low water level alert (example)'), subtitle: Text('Delivered to owner & tenants when below threshold')),
          ListTile(leading: Icon(Icons.water_damage_outlined, color: Colors.red), title: Text('Potential leakage detected'), subtitle: Text('Owner notified immediately when threshold criteria met')),
          ListTile(leading: Icon(Icons.receipt_long, color: Colors.blue), title: Text('New water bill generated'), subtitle: Text('Tenants notified with amount payable')),
          ListTile(leading: Icon(Icons.cleaning_services, color: Colors.teal), title: Text('Tank cleaning recommended/completed'), subtitle: Text('Status updates shown when available')),
          ListTile(leading: Icon(Icons.toggle_on, color: Colors.green), title: Text('Water supply ON/OFF'), subtitle: Text('Control actions and confirmations logged')),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoPill({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
        Text(value),
      ]),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  const _StatTile({required this.title, required this.value, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}
