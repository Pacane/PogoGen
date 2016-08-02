void applyNewReleaseAnyRule(
    Map<String, dynamic> config, Map<String, dynamic> newRule) {
  final releaseRules = config['release'] as Map<String, dynamic>;

  releaseRules['any'] = newRule;
}
