import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/formatters.dart';

class PortfolioSummaryCard extends StatelessWidget {
  final double totalValue;
  final double totalPnl;
  final double totalPnlPercent;

  const PortfolioSummaryCard({
    super.key,
    required this.totalValue,
    required this.totalPnl,
    required this.totalPnlPercent,
  });

  @override
  Widget build(BuildContext context) {
    final isGain = totalPnl >= 0;
    final changeColor = isGain ? AppColors.primaryFixed : AppColors.tertiaryFixed;
    final sign = isGain ? '+' : '';

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.portfolioGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Portfolio',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
              fontWeight: FontWeight.w500,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            Formatters.formatINR(totalValue),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: changeColor.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isGain ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                      color: changeColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$sign${Formatters.formatPercent(totalPnlPercent, showSign: false)}  '
                      '$sign${Formatters.formatINRCompact(totalPnl.abs())}',
                      style: TextStyle(
                        color: changeColor,
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
                'All time',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
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








