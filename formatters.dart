import 'package:intl/intl.dart';

String formatLiters(double liters) => '${liters.toStringAsFixed(0)} L';
String formatPercent(double fraction) => '${(fraction * 100).toStringAsFixed(0)}%';
String formatMoney(num value, {String symbol = 'Rs. '}) => '$symbol${value.toStringAsFixed(2)}';
String formatDateTime(DateTime dt) => DateFormat('MMM d, y • h:mm a').format(dt);
String formatDate(DateTime dt) => DateFormat('MMM d, y').format(dt);
