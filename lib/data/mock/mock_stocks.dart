import '../models/stock.dart';
import '../../core/utils/chart_helpers.dart';

class MockStocks {
  MockStocks._();

  static List<Stock> all = [
    _build(
      id: 'aapl',
      symbol: 'AAPL',
      name: 'Apple Inc.',
      sector: 'Technology',
      price: 189.43,
      changePercent: 1.34,
      changeAmount: 2.50,
      isINR: false,
      peRatio: 28.5,
      marketCap: 2.94e12,
      week52High: 198.23,
      week52Low: 143.90,
      volume: 52e6,
      description:
          'Apple Inc. designs, manufactures, and markets smartphones, personal computers, tablets, wearables, and accessories worldwide. The company offers iPhone, Mac, iPad, and wearables including AirPods, Apple TV, Apple Watch, and HomePod.',
    ),
    _build(
      id: 'tsla',
      symbol: 'TSLA',
      name: 'Tesla, Inc.',
      sector: 'Automotive',
      price: 214.11,
      changePercent: -0.85,
      changeAmount: -1.83,
      isINR: false,
      peRatio: 63.4,
      marketCap: 680e9,
      week52High: 278.98,
      week52Low: 138.80,
      volume: 96e6,
      description:
          'Tesla, Inc. designs, develops, manufactures, leases, and sells electric vehicles, energy generation and storage systems, and related services in the United States, China, and internationally.',
    ),
    _build(
      id: 'nvda',
      symbol: 'NVDA',
      name: 'NVIDIA Corporation',
      sector: 'Technology',
      price: 452.10,
      changePercent: 3.41,
      changeAmount: 14.91,
      isINR: false,
      peRatio: 115.2,
      marketCap: 1.11e12,
      week52High: 502.66,
      week52Low: 180.96,
      volume: 43e6,
      description:
          'NVIDIA Corporation provides graphics, and compute and networking solutions in the United States, Taiwan, China, and internationally. The company operates through two segments: Graphics and Compute & Networking.',
    ),
    _build(
      id: 'msft',
      symbol: 'MSFT',
      name: 'Microsoft Corporation',
      sector: 'Technology',
      price: 320.45,
      changePercent: 0.50,
      changeAmount: 1.60,
      isINR: false,
      peRatio: 32.1,
      marketCap: 2.38e12,
      week52High: 349.67,
      week52Low: 245.61,
      volume: 24e6,
      description:
          'Microsoft Corporation develops, licenses, and supports software, services, devices, and solutions worldwide. The company operates through Productivity and Business Processes, Intelligent Cloud, and More Personal Computing segments.',
    ),
    _build(
      id: 'reliance',
      symbol: 'RELIANCE',
      name: 'Reliance Industries',
      sector: 'Energy',
      price: 2485.60,
      changePercent: 1.12,
      changeAmount: 27.55,
      peRatio: 24.3,
      marketCap: 16.82e12,
      week52High: 2856.15,
      week52Low: 2150.00,
      volume: 8.2e6,
      description:
          'Reliance Industries Limited is a conglomerate holding company headquartered in Mumbai. It operates across energy, petrochemicals, natural gas, retail, telecommunications, mass media, and textiles segments.',
    ),
    _build(
      id: 'tcs',
      symbol: 'TCS',
      name: 'Tata Consultancy Services',
      sector: 'Technology',
      price: 3412.40,
      changePercent: 0.28,
      changeAmount: 9.55,
      peRatio: 27.8,
      marketCap: 12.4e12,
      week52High: 4043.75,
      week52Low: 3011.20,
      volume: 2.4e6,
      description:
          'Tata Consultancy Services Limited (TCS) is a global leader in IT services, consulting, and business solutions. The company offers a portfolio of IT, BPS, infrastructure, engineering and assurance services',
    ),
    _build(
      id: 'hdfcbank',
      symbol: 'HDFCBANK',
      name: 'HDFC Bank',
      sector: 'Finance',
      price: 1620.35,
      changePercent: -0.42,
      changeAmount: -6.88,
      peRatio: 19.2,
      marketCap: 12.3e12,
      week52High: 1757.80,
      week52Low: 1363.55,
      volume: 12.1e6,
      description:
          'HDFC Bank Limited provides banking and financial services to individuals and businesses in India, Bahrain, Hong Kong, and Dubai. The bank operates through Treasury, Retail Banking, Wholesale Banking, and Other Banking Business segments.',
    ),
    _build(
      id: 'tatamotors',
      symbol: 'TATAMOTORS',
      name: 'Tata Motors Ltd.',
      sector: 'Automotive',
      price: 857.80,
      changePercent: 2.15,
      changeAmount: 18.05,
      peRatio: 14.5,
      marketCap: 3.17e12,
      week52High: 1028.50,
      week52Low: 618.90,
      volume: 18.6e6,
      description:
          'Tata Motors Limited designs, develops, manufactures, and sells a wide range of cars, sports utility vehicles, trucks, buses and defense vehicles. The company operates through Tata Commercial Vehicles, Tata Passenger Vehicles, and Jaguar Land Rover segments.',
    ),
    _build(
      id: 'infy',
      symbol: 'INFY',
      name: 'Infosys Ltd.',
      sector: 'Technology',
      price: 1418.65,
      changePercent: -1.05,
      changeAmount: -15.10,
      peRatio: 22.4,
      marketCap: 5.88e12,
      week52High: 1858.25,
      week52Low: 1299.75,
      volume: 9.8e6,
      description:
          'Infosys Limited provides consulting, technology, outsourcing, and next-generation digital services in North America, Europe, India, and internationally. It operates through Financial Services, Retail, Communication, Energy, and Manufacturing segments.',
    ),
    _build(
      id: 'itc',
      symbol: 'ITC',
      name: 'ITC Ltd.',
      sector: 'FMCG',
      price: 432.50,
      changePercent: 0.68,
      changeAmount: 2.93,
      peRatio: 26.1,
      marketCap: 5.4e12,
      week52High: 500.70,
      week52Low: 399.20,
      volume: 14.2e6,
      description:
          'ITC Limited operates in FMCG, Hotels, Paperboards, Packaging & Printing, and Agribusiness segments. The company is a major producer of cigarettes and also has a growing presence in branded packaged foods, personal care, and education stationery.',
    ),
    _build(
      id: 'wipro',
      symbol: 'WIPRO',
      name: 'Wipro Ltd.',
      sector: 'Technology',
      price: 452.80,
      changePercent: -0.33,
      changeAmount: -1.50,
      peRatio: 20.8,
      marketCap: 2.35e12,
      week52High: 562.70,
      week52Low: 392.00,
      volume: 6.3e6,
      description:
          'Wipro Limited provides information technology, consulting, and business process services worldwide. The company operates through IT Services and IT Products segments, serving industries including banking, healthcare, manufacturing, and retail.',
    ),
    _build(
      id: 'axisbank',
      symbol: 'AXISBANK',
      name: 'Axis Bank Ltd.',
      sector: 'Finance',
      price: 1024.30,
      changePercent: 1.88,
      changeAmount: 18.93,
      peRatio: 16.3,
      marketCap: 3.15e12,
      week52High: 1151.80,
      week52Low: 877.50,
      volume: 11.4e6,
      description:
          'Axis Bank Limited provides banking and financial services in India and internationally. The bank operates through Treasury, Retail Banking, Corporate/Wholesale Banking, and Other Banking Business segments. It offers savings accounts, current accounts, fixed deposits, and home loans.',
    ),
  ];

  static Stock _build({
    required String id,
    required String symbol,
    required String name,
    required String sector,
    required double price,
    required double changePercent,
    required double changeAmount,
    required String description,
    required double marketCap,
    required double peRatio,
    required double week52High,
    required double week52Low,
    required double volume,
    bool isINR = true,
  }) {
    final history = ChartHelpers.generateHistory(
      basePrice: price,
      days: 365,
      volatility: 0.012 + (changePercent.abs() * 0.002),
    );
    return Stock(
      id: id,
      symbol: symbol,
      name: name,
      sector: sector,
      price: price,
      changePercent: changePercent,
      changeAmount: changeAmount,
      description: description,
      marketCap: marketCap,
      peRatio: peRatio,
      week52High: week52High,
      week52Low: week52Low,
      volume: volume,
      isINR: isINR,
      historicalData: history,
    );
  }

  static Stock? findById(String id) {
    try {
      return all.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  static Stock? findBySymbol(String symbol) {
    try {
      return all.firstWhere(
          (s) => s.symbol.toLowerCase() == symbol.toLowerCase());
    } catch (_) {
      return null;
    }
  }
}






