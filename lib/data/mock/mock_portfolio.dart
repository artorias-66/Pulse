import '../models/holding.dart';
import 'mock_stocks.dart';

class MockPortfolio {
  MockPortfolio._();

  static PortfolioSummary get summary {
    return PortfolioSummary(holdings: holdings);
  }

  static List<Holding> get holdings => [
        Holding(
          stockId: 'reliance',
          symbol: 'RELIANCE',
          name: 'Reliance Industries',
          quantity: 340,
          avgBuyPrice: 2341.50,
          currentPrice: MockStocks.findById('reliance')?.price ?? 2485.60,
          sector: 'Energy',
        ),
        Holding(
          stockId: 'tcs',
          symbol: 'TCS',
          name: 'Tata Consultancy Services',
          quantity: 150,
          avgBuyPrice: 3268.40,
          currentPrice: MockStocks.findById('tcs')?.price ?? 3412.40,
          sector: 'Technology',
        ),
        Holding(
          stockId: 'hdfcbank',
          symbol: 'HDFCBANK',
          name: 'HDFC Bank',
          quantity: 301,
          avgBuyPrice: 1725.20,
          currentPrice: MockStocks.findById('hdfcbank')?.price ?? 1620.35,
          sector: 'Finance',
        ),
        Holding(
          stockId: 'infy',
          symbol: 'INFY',
          name: 'Infosys Ltd.',
          quantity: 200,
          avgBuyPrice: 1357.80,
          currentPrice: MockStocks.findById('infy')?.price ?? 1418.65,
          sector: 'Technology',
        ),
        Holding(
          stockId: 'itc',
          symbol: 'ITC',
          name: 'ITC Ltd.',
          quantity: 500,
          avgBuyPrice: 422.10,
          currentPrice: MockStocks.findById('itc')?.price ?? 432.50,
          sector: 'FMCG',
        ),
      ];
}






