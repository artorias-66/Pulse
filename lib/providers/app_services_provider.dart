import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/analytics/analytics_service.dart';
import '../core/flags/feature_flags.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/stock_repository.dart';

final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  return const FeatureFlags();
});

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return DebugAnalyticsService();
});

final stockRepositoryProvider = Provider<StockRepository>((ref) {
  return MockStockRepository();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return LocalAuthRepository();
});
