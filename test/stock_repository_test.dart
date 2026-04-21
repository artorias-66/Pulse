import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/data/repositories/stock_repository.dart';

void main() {
  test('MockStockRepository returns stock list', () async {
    final repository = MockStockRepository();
    final stocks = await repository.fetchStocks();

    expect(stocks.isNotEmpty, true);
  });
}
