import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/gemini_service.dart';

class DiagnosticState {
  final double overallMatchScore;
  final double technicalSkill;
  final double domainKnowledge;
  final double analyticalCapability;
  final double toolsMastery;
  final double leadershipComm;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendedJobs;
  final List<String> criticalGaps;
  final bool isLoading;
  final bool isEvaluated;

  DiagnosticState({
    this.overallMatchScore = 0.0,
    this.technicalSkill = 0.0,
    this.domainKnowledge = 0.0,
    this.analyticalCapability = 0.0,
    this.toolsMastery = 0.0,
    this.leadershipComm = 0.0,
    this.strengths = const [],
    this.weaknesses = const [],
    this.recommendedJobs = const [],
    this.criticalGaps = const [],
    this.isLoading = false,
    this.isEvaluated = false,
  });

  DiagnosticState copyWith({
    double? overallMatchScore,
    double? technicalSkill,
    double? domainKnowledge,
    double? analyticalCapability,
    double? toolsMastery,
    double? leadershipComm,
    List<String>? strengths,
    List<String>? weaknesses,
    List<String>? recommendedJobs,
    List<String>? criticalGaps,
    bool? isLoading,
    bool? isEvaluated,
  }) {
    return DiagnosticState(
      overallMatchScore: overallMatchScore ?? this.overallMatchScore,
      technicalSkill: technicalSkill ?? this.technicalSkill,
      domainKnowledge: domainKnowledge ?? this.domainKnowledge,
      analyticalCapability: analyticalCapability ?? this.analyticalCapability,
      toolsMastery: toolsMastery ?? this.toolsMastery,
      leadershipComm: leadershipComm ?? this.leadershipComm,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      recommendedJobs: recommendedJobs ?? this.recommendedJobs,
      criticalGaps: criticalGaps ?? this.criticalGaps,
      isLoading: isLoading ?? this.isLoading,
      isEvaluated: isEvaluated ?? this.isEvaluated,
    );
  }
}

class DiagnosticNotifier extends StateNotifier<DiagnosticState> {
  DiagnosticNotifier() : super(DiagnosticState());

  Future<void> runLiveGeminiDiagnostic({
    required String targetRole,
    required String resumeText,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await GeminiService.analyzeCandidateCV(
      targetRole: targetRole,
      resumeText: resumeText,
    );

    List<String> parseList(dynamic raw) {
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return [];
    }

    state = state.copyWith(
      overallMatchScore: (result['overallMatchScore'] as num? ?? 80).toDouble(),
      technicalSkill: (result['technicalSkill'] as num? ?? 80).toDouble(),
      domainKnowledge: (result['domainKnowledge'] as num? ?? 80).toDouble(),
      analyticalCapability: (result['analyticalCapability'] as num? ?? 80).toDouble(),
      toolsMastery: (result['toolsMastery'] as num? ?? 80).toDouble(),
      leadershipComm: (result['leadershipComm'] as num? ?? 80).toDouble(),
      strengths: parseList(result['strengths']),
      weaknesses: parseList(result['weaknesses']),
      recommendedJobs: parseList(result['recommendedJobs']),
      criticalGaps: parseList(result['criticalGaps']),
      isLoading: false,
      isEvaluated: true,
    );
  }
}

final diagnosticProvider =
    StateNotifierProvider<DiagnosticNotifier, DiagnosticState>((ref) {
  return DiagnosticNotifier();
});