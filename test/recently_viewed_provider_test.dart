import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse/providers/stock_provider.dart';

void main() {
  test('recently viewed keeps newest first and deduplicates', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(recentlyViewedProvider.notifier);

    await notifier.record('aapl');
    await notifier.record('tsla');
    await notifier.record('aapl');

    final ids = container.read(recentlyViewedProvider);
    expect(ids, ['aapl', 'tsla']);
  });

  test('recently viewed caps list at 8 items', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(recentlyViewedProvider.notifier);

    for (var i = 0; i < 10; i++) {
      await notifier.record('id_$i');
    }

    final ids = container.read(recentlyViewedProvider);
    expect(ids.length, 8);
    expect(ids.first, 'id_9');
    expect(ids.last, 'id_2');
  });
}
