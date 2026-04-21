class FeatureFlags {
  final bool enableAnalytics;
  final bool enableOrderFlowTracking;
  final bool enableExperimentalUi;

  const FeatureFlags({
    this.enableAnalytics = true,
    this.enableOrderFlowTracking = true,
    this.enableExperimentalUi = false,
  });
}
