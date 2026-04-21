import 'dart:async';

import '../mock/mock_stocks.dart';
import '../models/stock.dart';

abstract class StockRepository {
  Future<List<Stock>> fetchStocks();
}

class MockStockRepository implements StockRepository {
  @override
  Future<List<Stock>> fetchStocks() async {
    // Keep a short delay so loading states remain visible in demos.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List<Stock>.from(MockStocks.all);
  }
}
