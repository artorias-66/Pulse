import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('formatPercent adds plus sign by default', () {
      expect(Formatters.formatPercent(3.21), '+3.21%');
      expect(Formatters.formatPercent(-1.50), '-1.50%');
    });

    test('formatChange uses absolute value after sign', () {
      expect(Formatters.formatChange(12.5, isINR: true), '+₹12.50');
      expect(Formatters.formatChange(-4.2, isINR: false), '-\$4.20');
    });

    test('formatVolume compacts values correctly', () {
      expect(Formatters.formatVolume(1200), '1.20K');
      expect(Formatters.formatVolume(250000), '2.50L');
      expect(Formatters.formatVolume(73000000), '7.30Cr');
    });
  });
}
