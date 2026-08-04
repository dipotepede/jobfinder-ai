import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/candidate_profile.dart';

class CandidateNotifier extends StateNotifier<CandidateProfile> {
  CandidateNotifier() : super(CandidateProfile()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    state = CandidateProfile(
      fullName: prefs.getString('fullName') ?? '',
      targetJobTitle: prefs.getString('targetJobTitle') ?? '',
      targetIndustry: prefs.getString('targetIndustry') ?? '',
      experienceLevel: prefs.getString('experienceLevel') ?? 'Entry-Level',
      resumeText: prefs.getString('resumeText') ?? '',
    );
  }

  Future<void> saveProfile(CandidateProfile updatedProfile) async {
    state = updatedProfile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('fullName', updatedProfile.fullName);
    await prefs.setString('targetJobTitle', updatedProfile.targetJobTitle);
    await prefs.setString('targetIndustry', updatedProfile.targetIndustry);
    await prefs.setString('experienceLevel', updatedProfile.experienceLevel);
    await prefs.setString('resumeText', updatedProfile.resumeText);
  }
}

final candidateProvider =
    StateNotifierProvider<CandidateNotifier, CandidateProfile>(
  (ref) => CandidateNotifier(),
);