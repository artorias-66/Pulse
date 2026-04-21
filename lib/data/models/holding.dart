/// Portfolio holding model
class Holding {
  final String stockId;
  final String symbol;
  final String name;
  final int quantity;
  final double avgBuyPrice;
  final double currentPrice;
  final String sector;

  const Holding({
    required this.stockId,
    required this.symbol,
    required this.name,
    required this.quantity,
    required this.avgBuyPrice,
    required this.currentPrice,
    required this.sector,
  });

  double get totalInvested => quantity * avgBuyPrice;
  double get currentValue => quantity * currentPrice;
  double get pnl => currentValue - totalInvested;
  double get pnlPercent => (pnl / totalInvested) * 100;
  bool get isProfit => pnl >= 0;

  Holding copyWith({double? currentPrice}) => Holding(
        stockId: stockId,
        symbol: symbol,
        name: name,
        quantity: quantity,
        avgBuyPrice: avgBuyPrice,
        currentPrice: currentPrice ?? this.currentPrice,
        sector: sector,
      );
}

class PortfolioSummary {
  final List<Holding> holdings;

  const PortfolioSummary({required this.holdings});

  double get totalInvested =>
      holdings.fold(0, (s, h) => s + h.totalInvested);

  double get totalCurrentValue =>
      holdings.fold(0, (s, h) => s + h.currentValue);

  double get totalPnl => totalCurrentValue - totalInvested;

  double get totalPnlPercent =>
      totalInvested == 0 ? 0 : (totalPnl / totalInvested) * 100;

  bool get isProfit => totalPnl >= 0;

  Map<String, double> get sectorAllocation {
    final totals = <String, double>{};
    for (final h in holdings) {
      totals[h.sector] = (totals[h.sector] ?? 0) + h.currentValue;
    }
    return totals;
  }
}






