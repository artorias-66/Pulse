import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/chart_helpers.dart';

/// Stock data model
class Stock {
  final String id;
  final String symbol;
  final String name;
  final String sector;
  final double price;
  final double changePercent;
  final double changeAmount;
  final String description;
  final double marketCap;
  final double peRatio;
  final double week52High;
  final double week52Low;
  final double volume;
  final bool isINR;
  final List<ChartPoint> historicalData;

  const Stock({
    required this.id,
    required this.symbol,
    required this.name,
    required this.sector,
    required this.price,
    required this.changePercent,
    required this.changeAmount,
    required this.description,
    required this.marketCap,
    required this.peRatio,
    required this.week52High,
    required this.week52Low,
    required this.volume,
    this.isINR = true,
    required this.historicalData,
  });

  bool get isGaining => changePercent >= 0;

  Color get changeColor =>
      isGaining ? AppColors.gain : AppColors.loss;

  Color get changeBgColor =>
      isGaining ? AppColors.gainBackground : AppColors.lossBackground;

  /// Sparkline data (last 14 points)
  List<double> get sparklineData =>
      historicalData.length >= 14
          ? historicalData
              .sublist(historicalData.length - 14)
              .map((e) => e.price)
              .toList()
          : historicalData.map((e) => e.price).toList();

  Stock copyWith({
    double? price,
    double? changePercent,
    double? changeAmount,
  }) {
    return Stock(
      id: id,
      symbol: symbol,
      name: name,
      sector: sector,
      price: price ?? this.price,
      changePercent: changePercent ?? this.changePercent,
      changeAmount: changeAmount ?? this.changeAmount,
      description: description,
      marketCap: marketCap,
      peRatio: peRatio,
      week52High: week52High,
      week52Low: week52Low,
      volume: volume,
      isINR: isINR,
      historicalData: historicalData,
    );
  }
}






