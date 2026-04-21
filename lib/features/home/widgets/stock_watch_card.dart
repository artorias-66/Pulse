import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/stock.dart';
import '../../../widgets/sparkline_chart.dart';
import '../../../widgets/price_chip.dart';
import '../../../widgets/app_widgets.dart';

class StockWatchCard extends StatelessWidget {
  final Stock stock;
  final VoidCallback onTap;

  const StockWatchCard({super.key, required this.stock, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.onSurface.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Hero(
                  tag: 'avatar_${stock.id}',
                  child: StockSymbolAvatar(symbol: stock.symbol, size: 36),
                ),
                PriceChip(
                  changePercent: stock.changePercent,
                  compact: true,
                  fontSize: 10,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Hero(
              tag: 'symbol_${stock.id}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  stock.symbol,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Plus Jakarta Sans',
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              stock.name,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
                fontFamily: 'Inter',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            SparklineChart(
              data: stock.sparklineData,
              isGain: stock.isGaining,
              height: 44,
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.formatPrice(stock.price, isINR: stock.isINR),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                fontFamily: 'Plus Jakarta Sans',
                color: AppColors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}








