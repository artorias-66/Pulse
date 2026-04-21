import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';

class PriceChip extends StatelessWidget {
  final double changePercent;
  final bool compact;
  final double fontSize;

  const PriceChip({
    super.key,
    required this.changePercent,
    this.compact = false,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isGain = changePercent >= 0;
    final bgColor = isGain ? AppColors.gainBackground : AppColors.lossBackground;
    final textColor = isGain ? AppColors.gain : AppColors.loss;
    final icon = isGain ? '▲' : '▼';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 3 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$icon ',
            style: TextStyle(
              color: textColor,
              fontSize: fontSize - 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            Formatters.formatPercent(changePercent.abs(), showSign: false),
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }
}








