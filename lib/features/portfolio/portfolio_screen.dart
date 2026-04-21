import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/holding.dart';
import '../../providers/portfolio_provider.dart';
import '../../widgets/skeleton_loader.dart';
import '../../widgets/app_widgets.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioSummaryProvider);
    final lastUpdated = ref.watch(portfolioLastUpdatedProvider);

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      onRefresh: () async {
        await ref.read(portfolioProvider.notifier).refresh();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ─── App Bar ────────────────────────────────────────────────
          const SliverAppBar(
            floating: true,
            scrolledUnderElevation: 0,
            titleSpacing: 20,
            title: Text('Portfolio'),
          ),

          if (lastUpdated != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Text(
                  'Last updated ${TimeOfDay.fromDateTime(lastUpdated).format(context)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),

          // ─── Content ────────────────────────────────────────────────
          portfolioAsync.when(
            loading: () => SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => i == 0
                    ? const Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        child: Column(
                          children: [
                            SkeletonBox(
                                width: double.infinity,
                                height: 140,
                                borderRadius: 20),
                            SizedBox(height: 16),
                            SkeletonBox(
                                width: double.infinity,
                                height: 200,
                                borderRadius: 16),
                          ],
                        ),
                      )
                    : const SkeletonListTile(),
                childCount: 6,
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: ErrorStateWidget(
                message: 'Failed to load portfolio',
                onRetry: () => ref.read(portfolioProvider.notifier).refresh(),
              ),
            ),
            data: (summary) => SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                _BalanceHeader(summary: summary),
                const SizedBox(height: 24),
                _AllocationSection(summary: summary),
                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Your Holdings',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ...summary.holdings
                    .map((h) => _HoldingTile(holding: h)),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Balance Header ───────────────────────────────────────────────────────────

class _BalanceHeader extends StatelessWidget {
  final PortfolioSummary summary;

  const _BalanceHeader({required this.summary});

  @override
  Widget build(BuildContext context) {
    final isProfit = summary.isProfit;
    final sign = isProfit ? '+' : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.portfolioGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Balance',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Formatters.formatINR(summary.totalCurrentValue),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
              fontFamily: 'Plus Jakarta Sans',
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isProfit
                          ? AppColors.primaryFixed
                          : AppColors.tertiaryFixed)
                      .withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isProfit
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                      color: isProfit
                          ? AppColors.primaryFixed
                          : AppColors.tertiaryFixed,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$sign${Formatters.formatPercent(summary.totalPnlPercent, showSign: false)}  '
                      '$sign${Formatters.formatINRCompact(summary.totalPnl.abs())}',
                      style: TextStyle(
                        color: isProfit
                            ? AppColors.primaryFixed
                            : AppColors.tertiaryFixed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'All time returns',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Allocation Pie Chart ─────────────────────────────────────────────────────

class _AllocationSection extends StatefulWidget {
  final PortfolioSummary summary;

  const _AllocationSection({required this.summary});

  @override
  State<_AllocationSection> createState() => _AllocationSectionState();
}

class _AllocationSectionState extends State<_AllocationSection> {
  int _touchedIndex = -1;

  static const _sectorColors = [
    AppColors.primary,
    Color(0xFF2196F3),
    AppColors.tertiary,
    Color(0xFF9C27B0),
    Color(0xFFFF9800),
  ];

  @override
  Widget build(BuildContext context) {
    final allocation = widget.summary.sectorAllocation;
    final total = widget.summary.totalCurrentValue;
    final sectors = allocation.keys.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Allocation',
              style: Theme.of(context).textTheme.titleSmall),
          Text(
            'Diversification across ${sectors.length} sectors',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Pie chart
              SizedBox(
                height: 130,
                width: 130,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, resp) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              resp == null ||
                              resp.touchedSection == null) {
                            _touchedIndex = -1;
                          } else {
                            _touchedIndex = resp
                                .touchedSection!.touchedSectionIndex;
                          }
                        });
                      },
                    ),
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: sectors.asMap().entries.map((e) {
                      final i = e.key;
                      final sector = e.value;
                      final value = allocation[sector]!;
                      final pct = (value / total * 100);
                      final isTouched = i == _touchedIndex;
                      return PieChartSectionData(
                        color: _sectorColors[i % _sectorColors.length],
                        value: value,
                        title: '${pct.toStringAsFixed(0)}%',
                        radius: isTouched ? 50 : 42,
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: 'Inter',
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Legend
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: sectors.asMap().entries.map((e) {
                    final i = e.key;
                    final sector = e.value;
                    final value = allocation[sector]!;
                    final pct = (value / total * 100);
                    final color = _sectorColors[i % _sectorColors.length];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              sector,
                              style: const TextStyle(
                                fontSize: 12,
                                fontFamily: 'Inter',
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: AppColors.onSurface,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Holding Tile ─────────────────────────────────────────────────────────────

class _HoldingTile extends StatelessWidget {
  final Holding holding;

  const _HoldingTile({required this.holding});

  @override
  Widget build(BuildContext context) {
    final isProfit = holding.isProfit;
    final sign = isProfit ? '+' : '';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            StockSymbolAvatar(symbol: holding.symbol, size: 44),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    holding.name,
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
                  Text(
                    '${holding.quantity} shares  ·  Avg ₹${holding.avgBuyPrice.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.onSurfaceVariant,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Formatters.formatINR(holding.currentValue),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Plus Jakarta Sans',
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isProfit
                        ? AppColors.gainBackground
                        : AppColors.lossBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$sign${holding.pnlPercent.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isProfit ? AppColors.gain : AppColors.loss,
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








