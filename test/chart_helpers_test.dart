import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/chart_helpers.dart';

void main() {
  group('ChartHelpers', () {
    test('minMax returns padded range for flat data', () {
      final points = [
        ChartPoint(date: DateTime(2025, 1, 1), price: 100),
        ChartPoint(date: DateTime(2025, 1, 2), price: 100),
      ];

      final (min, max) = ChartHelpers.minMax(points);

      expect(min, lessThan(100));
      expect(max, greaterThan(100));
    });

    test('subset returns recent data for timeframe', () {
      final now = DateTime.now();
      final points = List.generate(
        40,
        (i) => ChartPoint(
          date: now.subtract(Duration(days: 39 - i)),
          price: 100.0 + i,
        ),
      );

      final oneWeek = ChartHelpers.subset(points, '1W');
      expect(oneWeek.length, lessThanOrEqualTo(points.length));
      expect(oneWeek.isNotEmpty, true);
    });

    test('normalize returns midpoint for equal bounds', () {
      expect(ChartHelpers.normalize(10, 5, 5), 0.5);
    });
  });
}
