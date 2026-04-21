import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/local_storage.dart';
import '../data/models/stock.dart';
import 'app_services_provider.dart';

// ─── All stocks ───────────────────────────────────────────────────────────────

class StockNotifier extends StateNotifier<AsyncValue<List<Stock>>> {
  StockNotifier(this._ref) : super(const AsyncValue.loading()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final stocks = await _ref.read(stockRepositoryProvider).fetchStocks();
      state = AsyncValue.data(stocks);
      _ref.read(stocksLastUpdatedProvider.notifier).state = DateTime.now();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    try {
      final stocks = await _ref.read(stockRepositoryProvider).fetchStocks();
      state = AsyncValue.data(stocks);
      _ref.read(stocksLastUpdatedProvider.notifier).state = DateTime.now();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final stockListProvider =
    StateNotifierProvider<StockNotifier, AsyncValue<List<Stock>>>(
  (ref) => StockNotifier(ref),
);

final stocksLastUpdatedProvider = StateProvider<DateTime?>((ref) => null);

// ─── Search query ─────────────────────────────────────────────────────────────

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredStocksProvider = Provider<List<Stock>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final stocks = ref.watch(stockListProvider).valueOrNull ?? [];
  if (query.isEmpty) return stocks;
  return stocks
      .where((s) =>
          s.name.toLowerCase().contains(query) ||
          s.symbol.toLowerCase().contains(query) ||
          s.sector.toLowerCase().contains(query))
      .toList();
});

// ─── Trending stocks (first 5 INR stocks) ────────────────────────────────────

final trendingStocksProvider = Provider<List<Stock>>((ref) {
  final stocks = ref.watch(stockListProvider).valueOrNull ?? [];
  return stocks.where((s) => s.isINR).take(5).toList();
});

// ─── Watchlist ────────────────────────────────────────────────────────────────

class WatchlistNotifier extends StateNotifier<List<String>> {
  WatchlistNotifier() : super(LocalStorage.loadWatchlist());

  Future<void> toggle(String stockId) async {
    if (state.contains(stockId)) {
      state = state.where((id) => id != stockId).toList();
    } else {
      state = [...state, stockId];
    }

    await LocalStorage.saveWatchlist(state);
  }

  bool isWatched(String stockId) => state.contains(stockId);
}

final watchlistProvider =
    StateNotifierProvider<WatchlistNotifier, List<String>>(
  (ref) => WatchlistNotifier(),
);

final watchlistStocksProvider = Provider<List<Stock>>((ref) {
  final watchlist = ref.watch(watchlistProvider);
  final stocks = ref.watch(stockListProvider).valueOrNull ?? [];
  return stocks.where((s) => watchlist.contains(s.id)).toList();
});

class RecentlyViewedNotifier extends StateNotifier<List<String>> {
  RecentlyViewedNotifier() : super(LocalStorage.loadRecentlyViewed());

  Future<void> record(String stockId) async {
    final withoutDuplicate = state.where((id) => id != stockId).toList();
    final next = [stockId, ...withoutDuplicate].take(8).toList();
    state = next;
    await LocalStorage.saveRecentlyViewed(next);
  }

  Future<void> clear() async {
    state = [];
    await LocalStorage.saveRecentlyViewed(state);
  }
}

final recentlyViewedProvider =
    StateNotifierProvider<RecentlyViewedNotifier, List<String>>(
  (ref) => RecentlyViewedNotifier(),
);

final recentlyViewedStocksProvider = Provider<List<Stock>>((ref) {
  final ids = ref.watch(recentlyViewedProvider);
  final stocks = ref.watch(stockListProvider).valueOrNull ?? [];
  final byId = {for (final stock in stocks) stock.id: stock};

  return ids
      .map((id) => byId[id])
      .whereType<Stock>()
      .toList(growable: false);
});

final stockByIdProvider = Provider.family<Stock?, String>((ref, id) {
  final stocks = ref.watch(stockListProvider).valueOrNull ?? [];
  try {
    return stocks.firstWhere((s) => s.id == id);
  } catch (_) {
    return null;
  }
});

// ─── Timeframe for stock detail chart ────────────────────────────────────────

final selectedTimeframeProvider = StateProvider<String>((ref) => '1M');

// ─── Categories ──────────────────────────────────────────────────────────────

final selectedCategoryProvider = StateProvider<String?>((ref) => null);

final categoriesProvider = Provider<List<String>>((ref) {
  final stocks = ref.watch(stockListProvider).valueOrNull ?? [];
  final sectors = stocks.map((s) => s.sector).toSet().toList()..sort();
  return ['All', ...sectors];
});

final categoryFilteredStocksProvider = Provider<List<Stock>>((ref) {
  final category = ref.watch(selectedCategoryProvider);
  final stocks = ref.watch(filteredStocksProvider);
  if (category == null || category == 'All') return stocks;
  return stocks.where((s) => s.sector == category).toList();
});






