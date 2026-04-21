import 'dart:math';

class ChartPoint {
  final DateTime date;
  final double price;

  const ChartPoint({required this.date, required this.price});
}

class ChartHelpers {
  ChartHelpers._();

  /// Generates realistic random walk price data
  static List<ChartPoint> generateHistory({
    required double basePrice,
    required int days,
    double volatility = 0.015,
    DateTime? endDate,
  }) {
    final rng = Random(basePrice.toInt());
    final end = endDate ?? DateTime.now();
    final start = end.subtract(Duration(days: days));
    final points = <ChartPoint>[];
    double price = basePrice * (0.85 + rng.nextDouble() * 0.15);

    for (int i = 0; i <= days; i++) {
      final date = start.add(Duration(days: i));
      final change = (rng.nextDouble() - 0.48) * volatility;
      price = price * (1 + change);
      points.add(ChartPoint(date: date, price: price));
    }
    // Force last point to match basePrice
    points[points.length - 1] = ChartPoint(date: end, price: basePrice);
    return points;
  }

  /// Returns min and max from a list of ChartPoints
  static (double min, double max) minMax(List<ChartPoint> points) {
    if (points.isEmpty) return (0.0, 1.0);
    double min = points.first.price;
    double max = points.first.price;
    for (final p in points) {
      if (p.price < min) min = p.price;
      if (p.price > max) max = p.price;
    }
    // Avoid flat chart (min == max) which causes fl_chart assertion
    if (max == min) {
      final bump = max * 0.02 + 1.0;
      return (min - bump, max + bump);
    }
    return (min, max);
  }

  /// Normalize a value between 0 and 1
  static double normalize(double value, double min, double max) {
    if (max == min) return 0.5;
    return (value - min) / (max - min);
  }

  /// Subsets data for different timeframes
  static List<ChartPoint> subset(List<ChartPoint> all, String timeframe) {
    final now = DateTime.now();
    DateTime cutoff;
    switch (timeframe) {
      case '1D':
        cutoff = now.subtract(const Duration(days: 1));
        break;
      case '1W':
        cutoff = now.subtract(const Duration(days: 7));
        break;
      case '1M':
        cutoff = now.subtract(const Duration(days: 30));
        break;
      case '1Y':
        cutoff = now.subtract(const Duration(days: 365));
        break;
      default:
        return all;
    }
    final filtered = all.where((p) => p.date.isAfter(cutoff)).toList();
    return filtered.isEmpty ? all.take(5).toList() : filtered;
  }
}






