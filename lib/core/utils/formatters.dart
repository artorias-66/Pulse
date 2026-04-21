import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _inrCompact = NumberFormat.compactCurrency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _inrFull = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final _usdCompact = NumberFormat.compactCurrency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String formatINR(double value) => _inrFull.format(value);
  static String formatINRCompact(double value) => _inrCompact.format(value);
  static String formatUSD(double value) => _usdCompact.format(value);

  static String formatPrice(double value, {bool isINR = true}) {
    final formatter = NumberFormat.currency(
      locale: isINR ? 'en_IN' : 'en_US',
      symbol: isINR ? '₹' : '\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  static String formatPercent(double value, {bool showSign = true}) {
    final sign = showSign && value >= 0 ? '+' : '';
    return '$sign${value.toStringAsFixed(2)}%';
  }

  static String formatChange(double value, {bool isINR = true}) {
    final sign = value >= 0 ? '+' : '-';
    final symbol = isINR ? '₹' : '\$';
    return '$sign$symbol${value.abs().toStringAsFixed(2)}';
  }

  static String formatMarketCap(double value) {
    if (value >= 1e12) return '₹${(value / 1e12).toStringAsFixed(2)}T';
    if (value >= 1e9) return '₹${(value / 1e9).toStringAsFixed(2)}B';
    if (value >= 1e7) return '₹${(value / 1e7).toStringAsFixed(2)}Cr';
    if (value >= 1e5) return '₹${(value / 1e5).toStringAsFixed(2)}L';
    return '₹${value.toStringAsFixed(0)}';
  }

  static String formatVolume(double value) {
    if (value >= 1e7) return '${(value / 1e7).toStringAsFixed(2)}Cr';
    if (value >= 1e5) return '${(value / 1e5).toStringAsFixed(2)}L';
    if (value >= 1e3) return '${(value / 1e3).toStringAsFixed(2)}K';
    return value.toStringAsFixed(0);
  }
}






