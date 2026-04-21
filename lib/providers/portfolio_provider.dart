import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/mock/mock_portfolio.dart';
import '../data/models/holding.dart';

// ─── Portfolio state ──────────────────────────────────────────────────────────

class PortfolioState {
  final AsyncValue<PortfolioSummary> summary;

  const PortfolioState({required this.summary});

  PortfolioState copyWith({AsyncValue<PortfolioSummary>? summary}) =>
      PortfolioState(summary: summary ?? this.summary);
}

class PortfolioNotifier extends StateNotifier<PortfolioState> {
  PortfolioNotifier(this._ref)
      : super(const PortfolioState(summary: AsyncValue.loading())) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    state = const PortfolioState(summary: AsyncValue.loading());
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      state = PortfolioState(
        summary: AsyncValue.data(MockPortfolio.summary),
      );
      _ref.read(portfolioLastUpdatedProvider.notifier).state = DateTime.now();
    } catch (e, st) {
      state = PortfolioState(summary: AsyncValue.error(e, st));
    }
  }

  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 700));
    state = PortfolioState(
      summary: AsyncValue.data(MockPortfolio.summary),
    );
    _ref.read(portfolioLastUpdatedProvider.notifier).state = DateTime.now();
  }
}

final portfolioProvider =
    StateNotifierProvider<PortfolioNotifier, PortfolioState>(
  (ref) => PortfolioNotifier(ref),
);

final portfolioLastUpdatedProvider = StateProvider<DateTime?>((ref) => null);

final portfolioSummaryProvider = Provider<AsyncValue<PortfolioSummary>>((ref) {
  return ref.watch(portfolioProvider).summary;
});






