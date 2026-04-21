import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../data/models/stock.dart';
import '../../../providers/stock_provider.dart';
import '../../../providers/app_services_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../widgets/skeleton_loader.dart';
import '../../../widgets/app_widgets.dart';
import 'widgets/portfolio_summary_card.dart';
import 'widgets/portfolio_chart.dart';
import 'widgets/stock_watch_card.dart';

class HomeScreen extends ConsumerWidget {
  final void Function(String stockId) onStockTap;

  const HomeScreen({super.key, required this.onStockTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> track(String name, Map<String, Object?> params) async {
      final flags = ref.read(featureFlagsProvider);
      if (!flags.enableAnalytics) return;
      await ref.read(analyticsServiceProvider).track(
            AnalyticsEvent(name, params: params),
          );
    }

    final portfolioAsync = ref.watch(portfolioSummaryProvider);
    final watchlistStocks = ref.watch(watchlistStocksProvider);
    final stocksAsync = ref.watch(stockListProvider);
    final stockLastUpdated = ref.watch(stocksLastUpdatedProvider);
    final portfolioLastUpdated = ref.watch(portfolioLastUpdatedProvider);

    final freshness = stockLastUpdated != null || portfolioLastUpdated != null
      ? [stockLastUpdated, portfolioLastUpdated]
        .whereType<DateTime>()
        .reduce((a, b) => a.isAfter(b) ? a : b)
      : null;

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      onRefresh: () async {
        await Future.wait([
          ref.read(stockListProvider.notifier).refresh(),
          ref.read(portfolioProvider.notifier).refresh(),
        ]);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ─── App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            scrolledUnderElevation: 0,
            titleSpacing: 20,
            title: const Text('Ledger'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
          ),

          // ─── Portfolio summary ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: portfolioAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonBox(
                        width: 120, height: 14, borderRadius: 4),
                    SizedBox(height: 8),
                    SkeletonBox(
                        width: 240, height: 38, borderRadius: 8),
                    SizedBox(height: 8),
                    SkeletonBox(
                        width: 180,
                        height: 28,
                        borderRadius: 20),
                  ],
                ),
              ),
              error: (e, _) => ErrorStateWidget(
                onRetry: () => ref.read(portfolioProvider.notifier).refresh(),
              ),
              data: (summary) => PortfolioSummaryCard(
                totalValue: summary.totalCurrentValue,
                totalPnl: summary.totalPnl,
                totalPnlPercent: summary.totalPnlPercent,
              ),
            ),
          ),

          if (freshness != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  'Last updated ${TimeOfDay.fromDateTime(freshness).format(context)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── Portfolio trend chart ────────────────────────────────────
          SliverToBoxAdapter(
            child: stocksAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SkeletonBox(
                    width: double.infinity,
                    height: 200,
                    borderRadius: 12),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (stocks) => PortfolioChart(stocks: stocks.take(3).toList()),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ─── Watchlist header ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Watchlist',
              actionLabel: 'See all',
              onAction: () {},
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 14)),

          // ─── Watchlist horizontal scroll ──────────────────────────────
          SliverToBoxAdapter(
            child: stocksAsync.when(
              loading: () => SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: 4,
                  itemBuilder: (_, __) => const SkeletonStockCard(),
                ),
              ),
              error: (_, __) => ErrorStateWidget(
                onRetry: () => ref.read(stockListProvider.notifier).refresh(),
              ),
              data: (_) {
                if (watchlistStocks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'Your watchlist is empty. Add stocks from Explore to track them here.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  );
                }

                return SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 20),
                    itemCount: watchlistStocks.length,
                    itemBuilder: (context, i) {
                      final stock = watchlistStocks[i];
                      return StockWatchCard(
                        stock: stock,
                        onTap: () {
                          ref.read(recentlyViewedProvider.notifier).record(stock.id);
                          track('stock_opened', {
                            'source': 'home_watchlist',
                            'stock_id': stock.id,
                          });
                          onStockTap(stock.id);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 28)),

          // ─── Market Today header ──────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Market Today',
              actionLabel: 'View all',
              onAction: () {},
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ─── Market list ──────────────────────────────────────────────
          stocksAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const SkeletonListTile(),
                childCount: 5,
              ),
            ),
            error: (_, __) => SliverToBoxAdapter(
              child: ErrorStateWidget(
                onRetry: () => ref.read(stockListProvider.notifier).refresh(),
              ),
            ),
            data: (stocks) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final stock = stocks[i];
                  return _MarketListTile(
                    stock: stock,
                    onTap: () {
                      ref.read(recentlyViewedProvider.notifier).record(stock.id);
                      track('stock_opened', {
                        'source': 'home_market_today',
                        'stock_id': stock.id,
                      });
                      onStockTap(stock.id);
                    },
                  );
                },
                childCount: stocks.length > 6 ? 6 : stocks.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─── Market List Tile ─────────────────────────────────────────────────────────

class _MarketListTile extends StatelessWidget {
  final Stock stock;
  final VoidCallback onTap;

  const _MarketListTile({required this.stock, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGain = stock.changePercent >= 0;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            StockSymbolAvatar(symbol: stock.symbol, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.symbol,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    stock.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stock.isINR
                      ? '₹${stock.price.toStringAsFixed(2)}'
                      : '\$${stock.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isGain
                        ? AppColors.gainBackground
                        : AppColors.lossBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${isGain ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isGain ? AppColors.gain : AppColors.loss,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}








