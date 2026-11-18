import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/utils/formatters.dart';

class UsageBillingScreen extends StatefulWidget {
  final bool renterView;
  const UsageBillingScreen({super.key, this.renterView = false});

  @override
  State<UsageBillingScreen> createState() => _UsageBillingScreenState();
}

class _UsageBillingScreenState extends State<UsageBillingScreen> {
  String _period = 'Monthly';
  double _pricePerLiter = 0.12;
  int _tenantCount = 4;
  final _govTariff = 0.08; // reference only

  @override
  Widget build(BuildContext context) {
    final isOwner = !widget.renterView;
    return Scaffold(
      appBar: AppBar(title: Text(isOwner ? 'Usage & Billing (Owner)' : 'Charges & Usage')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text('Water Consumption', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                  DropdownButton<String>(
                    value: _period,
                    items: const [DropdownMenuItem(value: 'Daily', child: Text('Daily')), DropdownMenuItem(value: 'Weekly', child: Text('Weekly')), DropdownMenuItem(value: 'Monthly', child: Text('Monthly'))],
                    onChanged: (v) => setState(() => _period = v ?? 'Monthly'),
                  ),
                ]),
                const SizedBox(height: 8),
                SizedBox(height: 180, child: _UsageChart(period: _period)),
                const SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  _chip(context, 'Total (${_period.toLowerCase()})', _period == 'Daily' ? '420 L' : _period == 'Weekly' ? '2,980 L' : '11,600 L'),
                  if (isOwner) _chip(context, 'Tenants', '$_tenantCount configured'),
                  if (!isOwner) _chip(context, 'Your share', _period == 'Monthly' ? '2,450 L' : _period == 'Weekly' ? '620 L' : '85 L'),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          if (isOwner) _ownerBillingCard(context) else _renterChargesCard(context),
          const SizedBox(height: 12),
          _recordsCard(context, isOwner),
        ],
      ),
    );
  }

  Widget _ownerBillingCard(BuildContext context) {
    final totalLiters = 11600.0;
    final totalCharge = totalLiters * _pricePerLiter;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Billing Management', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Water price per unit (owner/rental)'),
            subtitle: Text('${formatMoney(_pricePerLiter)} per litre (editable)'),
            trailing: IconButton(icon: const Icon(Icons.edit), onPressed: _editPrice),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Government water tariff (reference)'),
            subtitle: Text('${formatMoney(_govTariff)} per litre • shown separately from rental charges'),
            leading: const Icon(Icons.info_outline),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Number of tenants in property'),
            subtitle: Text('$_tenantCount tenants (used for allocation/billing settings)'),
            trailing: IconButton(icon: const Icon(Icons.group_add_outlined), onPressed: _editTenants),
          ),
          const Divider(),
          _row('Total consumption (month)', '${totalLiters.toStringAsFixed(0)} L'),
          _row('Calculated total charges', formatMoney(totalCharge)),
          const SizedBox(height: 8),
          Text('Individual/allocated tenant consumption records are shown where supported by hardware configuration.', style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }

  Widget _renterChargesCard(BuildContext context) {
    final liters = 2450.0;
    final amount = liters * _pricePerLiter;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your Water Charges', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _row('Applicable price per unit', '${formatMoney(_pricePerLiter)} / L'),
          _row('Recorded consumption (month)', '${liters.toStringAsFixed(0)} L'),
          _row('Total amount payable', formatMoney(amount)),
          const SizedBox(height: 8),
          Row(children: [
            const Text('Payment status: ', style: TextStyle(fontWeight: FontWeight.w500)),
            Chip(label: const Text('Pending'), backgroundColor: Colors.orange.withValues(alpha: 0.2)),
          ]),
          const SizedBox(height: 4),
          Text('Pricing is set by the property owner. Billing method may be allocation-based depending on configuration.', style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }

  Widget _recordsCard(BuildContext context, bool isOwner) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isOwner ? 'Tenant Consumption & Payment Records' : 'Historical Consumption & Payments', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (isOwner) ...const [
            ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Text('A')), title: Text('Tenant A - Unit 1'), subtitle: Text('2,450 L • Rs. 294.00'), trailing: Chip(label: Text('Pending'))),
            ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Text('B')), title: Text('Tenant B - Unit 2'), subtitle: Text('2,900 L • Rs. 348.00'), trailing: Chip(label: Text('Paid'))),
            ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Text('C')), title: Text('Tenant C - Unit 3'), subtitle: Text('3,100 L • Rs. 372.00'), trailing: Chip(label: Text('Paid'))),
            ListTile(contentPadding: EdgeInsets.zero, leading: CircleAvatar(child: Text('D')), title: Text('Tenant D - Unit 4'), subtitle: Text('3,150 L • Rs. 378.00'), trailing: Chip(label: Text('Pending'))),
          ] else ...const [
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.history), title: Text('Oct 2026'), subtitle: Text('2,380 L • Rs. 285.60'), trailing: Text('Paid', style: TextStyle(color: Colors.green))),
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.history), title: Text('Sep 2026'), subtitle: Text('2,510 L • Rs. 301.20'), trailing: Text('Paid', style: TextStyle(color: Colors.green))),
            ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.history), title: Text('Nov 2026 (current)'), subtitle: Text('2,450 L • Rs. 294.00'), trailing: Text('Pending', style: TextStyle(color: Colors.orange))),
          ],
          const SizedBox(height: 4),
          Text('Daily/weekly/monthly summaries and historical usage available (mock data).', style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, String value) => Chip(label: Text('$label: $value'));
  Widget _row(String a, String b) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(a), Text(b, style: const TextStyle(fontWeight: FontWeight.w600))]));

  Future<void> _editPrice() async {
    final c = TextEditingController(text: _pricePerLiter.toStringAsFixed(2));
    final v = await showDialog<double>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Set price per litre'),
      content: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(prefixText: 'Rs. ')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, double.tryParse(c.text)), child: const Text('Save'))],
    ));
    if (v != null && v > 0) setState(() => _pricePerLiter = v);
  }

  Future<void> _editTenants() async {
    final c = TextEditingController(text: _tenantCount.toString());
    final v = await showDialog<int>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Configure number of tenants'),
      content: TextField(controller: c, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Tenants')),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(ctx, int.tryParse(c.text)), child: const Text('Save'))],
    ));
    if (v != null && v > 0) setState(() => _tenantCount = v);
  }
}

class _UsageChart extends StatelessWidget {
  final String period;
  const _UsageChart({required this.period});

  @override
  Widget build(BuildContext context) {
    final spots = switch (period) {
      'Daily' => [const FlSpot(0, 30), const FlSpot(1, 45), const FlSpot(2, 20), const FlSpot(3, 60), const FlSpot(4, 50), const FlSpot(5, 70), const FlSpot(6, 40)],
      'Weekly' => [const FlSpot(0, 350), const FlSpot(1, 420), const FlSpot(2, 390), const FlSpot(3, 460), const FlSpot(4, 410), const FlSpot(5, 480), const FlSpot(6, 470)],
      _ => [const FlSpot(0, 9.5), const FlSpot(1, 10.2), const FlSpot(2, 11.0), const FlSpot(3, 10.8), const FlSpot(4, 11.6), const FlSpot(5, 10.9), const FlSpot(6, 11.6)],
    };
    return LineChart(LineChartData(
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      titlesData: const FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
      borderData: FlBorderData(show: false),
      lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: Theme.of(context).colorScheme.primary, barWidth: 3, dotData: const FlDotData(show: false), belowBarData: BarAreaData(show: true, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)))],
    ));
  }
}
