import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/analytics/analytics_service.dart';
import '../../providers/app_services_provider.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/app_widgets.dart';
import '../../widgets/price_chip.dart';
import '../../widgets/sparkline_chart.dart';
import '../../data/models/stock.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  final void Function(String stockId) onStockTap;

  const ExploreScreen({super.key, required this.onStockTap});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(searchQueryProvider),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), () {
      ref.read(searchQueryProvider.notifier).state = value;

      final flags = ref.read(featureFlagsProvider);
      if (flags.enableAnalytics && value.trim().isNotEmpty) {
        ref.read(analyticsServiceProvider).track(
              AnalyticsEvent('stock_search_typed', params: {
                'query_length': value.trim().length,
              }),
            );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final stocksAsync = ref.watch(stockListProvider);
    final query = ref.watch(searchQueryProvider);
    final recentlyViewedStocks = ref.watch(recentlyViewedStocksProvider);
    final filtered = ref.watch(categoryFilteredStocksProvider);
    final categories = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      onRefresh: () async {
        await ref.read(stockListProvider.notifier).refresh();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ─── App Bar ────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            scrolledUnderElevation: 0,
            titleSpacing: 20,
            title: const Text('Explore'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search stocks, sectors…',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.onSurfaceVariant),
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded,
                                color: AppColors.onSurfaceVariant),
                            onPressed: () {
                              _searchDebounce?.cancel();
                              _searchController.clear();
                              ref.read(searchQueryProvider.notifier).state = '';
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),

          if (query.isEmpty && recentlyViewedStocks.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Recently Viewed',
                actionLabel: 'Clear',
                onAction: () =>
                    ref.read(recentlyViewedProvider.notifier).clear(),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: recentlyViewedStocks.length,
                  itemBuilder: (context, i) {
                    final stock = recentlyViewedStocks[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(stock.symbol),
                        onPressed: () {
                          widget.onStockTap(stock.id);
                        },
                        backgroundColor: AppColors.surfaceContainerLow,
                        labelStyle: const TextStyle(
                          color: AppColors.onSurface,
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 18)),
          ],

          // ─── Category chips ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: stocksAsync.maybeWhen(
              orElse: () => const SizedBox.shrink(),
              data: (_) => SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: categories.length,
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final isActive =
                        selectedCategory == cat ||
                        (cat == 'All' && selectedCategory == null);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        ref.read(selectedCategoryProvider.notifier).state =
                            cat == 'All' ? null : cat;
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            color: isActive
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // ─── Trending / results header ────────────────────────────────
        SliverToBoxAdapter(
          child: SectionHeader(
            title: query.isEmpty ? 'Market Movers' : 'Search Results',
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // ─── Stock List ──────────────────────────────────────────────
          stocksAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, __) => const SkeletonListTile(),
                childCount: 8,
              ),
            ),
            error: (_, __) => SliverToBoxAdapter(
              child: ErrorStateWidget(
                onRetry: () => ref.read(stockListProvider.notifier).refresh(),
              ),
            ),
            data: (_) {
              if (filtered.isEmpty) {
                return SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.outlineVariant),
                        const SizedBox(height: 12),
                        Text(
                          'No stocks found for "$query"',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _ExploreStockTile(
                    stock: filtered[i],
                    onTap: () {
                      final stock = filtered[i];
                      ref.read(recentlyViewedProvider.notifier).record(stock.id);
                      final flags = ref.read(featureFlagsProvider);
                      if (flags.enableAnalytics) {
                        ref.read(analyticsServiceProvider).track(
                              AnalyticsEvent('stock_opened', params: {
                                'source': 'explore',
                                'stock_id': stock.id,
                              }),
                            );
                      }
                      widget.onStockTap(stock.id);
                    },
                  ),
                  childCount: filtered.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _ExploreStockTile extends StatelessWidget {
  final Stock stock;
  final VoidCallback onTap;

  const _ExploreStockTile({required this.stock, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            StockSymbolAvatar(symbol: stock.symbol, size: 46),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stock.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Plus Jakarta Sans',
                      color: AppColors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        stock.symbol,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.onSurfaceVariant,
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          stock.sector,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.onSurfaceVariant,
                              fontFamily: 'Inter'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 70,
              height: 36,
              child: SparklineChart(
                data: stock.sparklineData,
                isGain: stock.isGaining,
                height: 36,
                width: 70,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  stock.isINR
                      ? '₹${stock.price.toStringAsFixed(0)}'
                      : '\$${stock.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                PriceChip(
                    changePercent: stock.changePercent, compact: true, fontSize: 11),
              ],
            ),
          ],
        ),
      ),
    );
  }
}








