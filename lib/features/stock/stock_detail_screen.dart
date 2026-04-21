import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/analytics/analytics_service.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/chart_helpers.dart';
import '../../data/models/stock.dart';
import '../../providers/app_services_provider.dart';
import '../../providers/stock_provider.dart';
import '../../widgets/price_chip.dart';
import '../../widgets/app_widgets.dart';

class StockDetailScreen extends ConsumerStatefulWidget {
  final String stockId;
  final VoidCallback? onBack;
  const StockDetailScreen({super.key, required this.stockId, this.onBack});

  @override
  ConsumerState<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends ConsumerState<StockDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    ref.read(recentlyViewedProvider.notifier).record(widget.stockId);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = ref.watch(stockByIdProvider(widget.stockId));
    if (stock == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Stock not found'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            _DetailAppBar(stock: stock, onBack: widget.onBack),
            SliverToBoxAdapter(
              child: _DetailBody(stock: stock),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── App Bar ──────────────────────────────────────────────────────────────────

class _DetailAppBar extends StatelessWidget {
  final Stock stock;
  final VoidCallback? onBack;

  const _DetailAppBar({required this.stock, this.onBack});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: onBack ?? () => Navigator.of(context).maybePop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'symbol_${stock.id}',
            child: Material(
              color: Colors.transparent,
              child: Text(
                stock.symbol,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ),
          Text(
            stock.name,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      actions: [
        Consumer(
          builder: (context, ref, _) {
            final watchlist = ref.watch(watchlistProvider);
            final isWatched = watchlist.contains(stock.id);
            return IconButton(
              icon: Icon(
                isWatched ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isWatched ? AppColors.primary : AppColors.onSurfaceVariant,
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(watchlistProvider.notifier).toggle(stock.id);
                final flags = ref.read(featureFlagsProvider);
                if (flags.enableAnalytics) {
                  ref.read(analyticsServiceProvider).track(
                        AnalyticsEvent('watchlist_toggled', params: {
                          'stock_id': stock.id,
                          'is_now_watched': !isWatched,
                        }),
                      );
                }
              },
            );
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}

// ─── Detail Body ──────────────────────────────────────────────────────────────

class _DetailBody extends ConsumerStatefulWidget {
  final Stock stock;

  const _DetailBody({required this.stock});

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  final _timeframes = ['1D', '1W', '1M', '1Y'];

  @override
  Widget build(BuildContext context) {
    final tf = ref.watch(selectedTimeframeProvider);
    final stock = widget.stock;
    final chartData = ChartHelpers.subset(stock.historicalData, tf);
    final (minY, maxY) = ChartHelpers.minMax(chartData);
    final range = maxY - minY;
    final pad = range > 0 ? range * 0.12 : maxY * 0.05 + 1.0;
    final hInterval = range > 0 ? range / 4 : (maxY * 0.05 + 1.0);

    final spots = chartData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.price);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Price + change
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatPrice(stock.price, isINR: stock.isINR),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: PriceChip(
                  changePercent: stock.changePercent,
                  fontSize: 14,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Text(
            '${stock.isGaining ? '+' : ''}${Formatters.formatChange(stock.changeAmount, isINR: stock.isINR)} today',
            style: TextStyle(
              color: stock.changeColor,
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 20),

          // Chart
          SizedBox(
            height: 200,
            child: spots.length < 2
                ? const Center(child: Text('No chart data'))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: hInterval,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppColors.outlineVariant.withValues(alpha: 0.2),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: const FlTitlesData(
                        show: true,
                        leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipColor: (_) =>
                              AppColors.surfaceContainerLowest,
                          tooltipRoundedRadius: 10,
                          getTooltipItems: (touchedSpots) => touchedSpots
                              .map((s) => LineTooltipItem(
                                    Formatters.formatPrice(s.y,
                                        isINR: stock.isINR),
                                    const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      minX: 0,
                      maxX: (spots.length - 1).toDouble(),
                      minY: minY - pad,
                      maxY: maxY + pad + (range == 0 ? 1.0 : 0),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: true,
                          curveSmoothness: 0.3,
                          color: stock.changeColor,
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          dotData: const FlDotData(show: false),
                          shadow: Shadow(
                            color: stock.changeColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                stock.changeColor.withValues(alpha: 0.15),
                                stock.changeColor.withValues(alpha: 0.0),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 400),
                  ),
          ),

          const SizedBox(height: 14),

          // Timeframe toggle
          Row(
            children: _timeframes.map((t) {
              final isActive = t == tf;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(selectedTimeframeProvider.notifier).state = t;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : AppColors.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 28),

          // Buy / Sell buttons
          Row(
            children: [
              Expanded(
                child: GradientButton(
                  label: 'Buy',
                  icon: Icons.add_rounded,
                  height: 52,
                  onTap: () => _showOrderSheet(context, stock, isBuy: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showOrderSheet(context, stock, isBuy: false),
                  icon: const Icon(Icons.remove_rounded),
                  label: const Text('Sell'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: AppColors.tertiary,
                    side: const BorderSide(
                        color: AppColors.tertiary, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Your Position
          _SectionCard(
            title: 'Your Position',
            child: Row(
              children: [
                _StatItem(
                    label: 'Invested',
                    value: Formatters.formatPrice(
                        stock.price * 50,
                        isINR: stock.isINR)),
                _StatItem(
                    label: 'Current Value',
                    value: Formatters.formatPrice(
                        stock.price * 52,
                        isINR: stock.isINR)),
                _StatItem(
                    label: 'P&L',
                    value: '+${Formatters.formatPrice(stock.price * 2, isINR: stock.isINR)}',
                    valueColor: AppColors.gain),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Key Stats
          _SectionCard(
            title: 'Key Stats',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _KeyStatTile(
                          label: 'Market Cap',
                          value: Formatters.formatMarketCap(stock.marketCap)),
                    ),
                    Expanded(
                      child: _KeyStatTile(
                          label: 'P/E Ratio',
                          value: stock.peRatio.toStringAsFixed(1)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _KeyStatTile(
                          label: '52W High',
                          value: Formatters.formatPrice(stock.week52High,
                              isINR: stock.isINR)),
                    ),
                    Expanded(
                      child: _KeyStatTile(
                          label: '52W Low',
                          value: Formatters.formatPrice(stock.week52Low,
                              isINR: stock.isINR)),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: _KeyStatTile(
                          label: 'Volume',
                          value: Formatters.formatVolume(stock.volume)),
                    ),
                    Expanded(
                      child: _KeyStatTile(
                          label: 'Sector', value: stock.sector),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // About
          _SectionCard(
            title: 'About ${stock.name}',
            child: Text(
              stock.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                fontFamily: 'Inter',
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _showOrderSheet(BuildContext context, Stock stock, {required bool isBuy}) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _OrderSheet(stock: stock, isBuy: isBuy),
    );
  }
}

// ─── Order Bottom Sheet (UI Only) ────────────────────────────────────────────

class _OrderSheet extends ConsumerStatefulWidget {
  final Stock stock;
  final bool isBuy;

  const _OrderSheet({required this.stock, required this.isBuy});

  @override
  ConsumerState<_OrderSheet> createState() => _OrderSheetState();
}

class _OrderSheetState extends ConsumerState<_OrderSheet> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final total = widget.stock.price * _qty;
    final isINR = widget.stock.isINR;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.isBuy ? 'Buy ${widget.stock.symbol}' : 'Sell ${widget.stock.symbol}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Quantity', style: TextStyle(fontFamily: 'Inter', fontSize: 14)),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: AppColors.primary,
                    onPressed: () => setState(() => _qty = (_qty - 1).clamp(1, 999)),
                  ),
                  Text('$_qty', style: Theme.of(context).textTheme.titleMedium),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: AppColors.primary,
                    onPressed: () => setState(() => _qty++),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600)),
              Text(
                Formatters.formatPrice(total, isINR: isINR),
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: widget.isBuy ? 'Confirm Buy' : 'Confirm Sell',
            onTap: () {
              HapticFeedback.heavyImpact();
              final flags = ref.read(featureFlagsProvider);
              if (flags.enableAnalytics && flags.enableOrderFlowTracking) {
                ref.read(analyticsServiceProvider).track(
                      AnalyticsEvent('order_confirmed', params: {
                        'stock_id': widget.stock.id,
                        'side': widget.isBuy ? 'buy' : 'sell',
                        'qty': _qty,
                        'total': total,
                      }),
                    );
              }

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    widget.isBuy
                        ? 'Order placed: Buy $_qty ${widget.stock.symbol}'
                        : 'Order placed: Sell $_qty ${widget.stock.symbol}',
                  ),
                  backgroundColor: widget.isBuy ? AppColors.primary : AppColors.tertiary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── Reusable sub-widgets ──────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _StatItem({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Plus Jakarta Sans',
                color: valueColor ?? cs.onSurface,
              )),
        ],
      ),
    );
  }
}

class _KeyStatTile extends StatelessWidget {
  final String label;
  final String value;

  const _KeyStatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                  fontFamily: 'Inter')),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontFamily: 'Plus Jakarta Sans',
                color: cs.onSurface,
              )),
        ],
      ),
    );
  }
}








