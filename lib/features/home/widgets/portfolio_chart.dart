import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/chart_helpers.dart';
import '../../../data/models/stock.dart';

class PortfolioChart extends StatefulWidget {
  final List<Stock> stocks;

  const PortfolioChart({super.key, required this.stocks});

  @override
  State<PortfolioChart> createState() => _PortfolioChartState();
}

class _PortfolioChartState extends State<PortfolioChart> {
  String _timeframe = '1M';
  final _timeframes = ['1D', '1W', '1M', '1Y'];

  List<ChartPoint> get _data {
    // Aggregate top 4 stock histories as a proxy portfolio trend
    if (widget.stocks.isEmpty) return [];
    final primary = widget.stocks.first.historicalData;
    final sub = ChartHelpers.subset(primary, _timeframe);
    return sub;
  }

  @override
  Widget build(BuildContext context) {
    final points = _data;
    if (points.isEmpty) return const SizedBox(height: 180);

    final (minY, maxY) = ChartHelpers.minMax(points);
    final range = maxY - minY;
    final padding = range > 0 ? range * 0.15 : maxY * 0.05 + 1.0;
    final hInterval = range > 0 ? range / 3 : (maxY * 0.05 + 1.0);

    final spots = points.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.price);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart
        SizedBox(
          height: 160,
          child: LineChart(
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
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (spot) =>
                      Theme.of(context).colorScheme.surfaceContainerLowest,
                  tooltipRoundedRadius: 10,
                  getTooltipItems: (spots) => spots
                      .map((s) => LineTooltipItem(
                            '₹${s.y.toStringAsFixed(0)}',
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
              minY: minY - padding,
              maxY: maxY + padding + (range == 0 ? 1.0 : 0),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: AppColors.primary,
                  barWidth: 2.5,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  shadow: Shadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 400),
          ),
        ),

        const SizedBox(height: 12),

        // Timeframe toggles
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: _timeframes.map((tf) {
              final isActive = tf == _timeframe;
              return GestureDetector(
                onTap: () => setState(() => _timeframe = tf),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primary
                        : Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tf,
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : AppColors.onSurfaceVariant,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}








