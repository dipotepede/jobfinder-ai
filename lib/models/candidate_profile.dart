class CandidateProfile {
  final String fullName;
  final String targetJobTitle;
  final String targetIndustry;
  final String experienceLevel;
  final String resumeText;

  CandidateProfile({
    this.fullName = '',
    this.targetJobTitle = '',
    this.targetIndustry = '',
    this.experienceLevel = 'Entry-Level',
    this.resumeText = '',
  });

  CandidateProfile copyWith({
    String? fullName,
    String? targetJobTitle,
    String? targetIndustry,
    String? experienceLevel,
    String? resumeText,
  }) {
    return CandidateProfile(
      fullName: fullName ?? this.fullName,
      targetJobTitle: targetJobTitle ?? this.targetJobTitle,
      targetIndustry: targetIndustry ?? this.targetIndustry,
      experienceLevel: experienceLevel ?? this.experienceLevel,
      resumeText: resumeText ?? this.resumeText,
    );
  }
}