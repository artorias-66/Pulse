import 'package:flutter_test/flutter_test.dart';
import 'package:pulse/core/flags/feature_flags.dart';

void main() {
  test('Feature flags default values are stable', () {
    const flags = FeatureFlags();

    expect(flags.enableAnalytics, true);
    expect(flags.enableOrderFlowTracking, true);
    expect(flags.enableExperimentalUi, false);
  });
}
