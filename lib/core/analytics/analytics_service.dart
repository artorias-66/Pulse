import 'package:flutter/foundation.dart';

class AnalyticsEvent {
  final String name;
  final Map<String, Object?> params;

  const AnalyticsEvent(this.name, {this.params = const {}});
}

abstract class AnalyticsService {
  Future<void> track(AnalyticsEvent event);
}

class DebugAnalyticsService implements AnalyticsService {
  @override
  Future<void> track(AnalyticsEvent event) async {
    debugPrint('analytics:${event.name} params=${event.params}');
  }
}
