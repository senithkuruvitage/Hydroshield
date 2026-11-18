import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/session.dart';
import '../../core/utils/formatters.dart';
import 'animated_water_tank.dart';

class RenterHomeScreen extends StatefulWidget {
  const RenterHomeScreen({super.key});

  @override
  State<RenterHomeScreen> createState() => _RenterHomeScreenState();
}

class _RenterHomeScreenState extends State<RenterHomeScreen> {
  final _rand = Random();
  double _level = 0.68;
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
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() {
        _level = (_level + (_rand.nextDouble() - 0.5) * 0.05).clamp(0.0, 1.0);
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
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Tenant Dashboard'),
          Text(session.propertyName.value ?? 'Property', style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                Text('Property Water Tank', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Center(child: AnimatedWaterTank(level: _level, state: _state, size: 220)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: [
                  Chip(label: Text(formatPercent(_level))),
                  Chip(label: Text(formatLiters(_level * TankCapacity.typical))),
                  Chip(label: Text(_state.label)),
                ]),
                Text('Last updated: ${formatDateTime(_lastUpdated)}', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Your Water Consumption', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.today), title: Text('Today'), trailing: Text('85 L')),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.view_week), title: Text('This Week'), trailing: Text('620 L')),
                const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.calendar_month), title: Text('This Month'), trailing: Text('2.45 m³')),
                const SizedBox(height: 4),
                Text('Historical records and charges are available in the Charges tab.', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Current Charges (Summary)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const ListTile(contentPadding: EdgeInsets.zero, title: Text('Applicable price per unit'), trailing: Text('Rs. 0.12 / L')),
                const ListTile(contentPadding: EdgeInsets.zero, title: Text('This month (estimated)'), trailing: Text('Rs. 294.00')),
                ListTile(contentPadding: EdgeInsets.zero, title: const Text('Payment status'), trailing: Chip(label: const Text('Pending'), backgroundColor: Colors.orange.withValues(alpha: 0.2))),
                const SizedBox(height: 4),
                Text('View owner payment details and records in the Payments tab. You cannot modify prices or hardware settings.', style: Theme.of(context).textTheme.bodySmall),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
