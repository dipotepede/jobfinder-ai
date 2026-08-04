class DiagnosticResult {
  final double technicalSkill;
  final double domainKnowledge;
  final double analyticalCapability;
  final double toolsMastery;
  final double leadershipComm;
  final double overallMatchScore;
  final List<String> criticalGaps;

  DiagnosticResult({
    required this.technicalSkill,
    required this.domainKnowledge,
    required this.analyticalCapability,
    required this.toolsMastery,
    required this.leadershipComm,
    required this.overallMatchScore,
    required this.criticalGaps,
  });

  // Target standard benchmark values for comparison
  static Map<String, double> get marketStandard => {
        'Technical': 85.0,
        'Domain': 80.0,
        'Analytical': 90.0,
        'Tools': 85.0,
        'Leadership': 75.0,
      };
}