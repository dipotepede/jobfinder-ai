import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnalyticsService {
  static String? _sessionId;
  static String? _currentScreen;
  static DateTime? _sessionStart;

  // Initialize candidate session on login
  static Future<void> startSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _sessionStart = DateTime.now();
    final doc = await FirebaseFirestore.instance.collection('user_sessions').add({
      'uid': user.uid,
      'email': user.email ?? 'Anonymous',
      'startTime': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
      'entryScreen': 'Screen 1: Candidate Onboarding',
      'exitScreen': 'Screen 1: Candidate Onboarding',
      'durationMinutes': 0,
    });
    _sessionId = doc.id;
    _currentScreen = 'Screen 1: Candidate Onboarding';
  }

  // Update exit page and length of stay on screen changes
  static Future<void> trackScreenChange(String newScreenTitle) async {
    if (_sessionId == null || _sessionStart == null) return;

    _currentScreen = newScreenTitle;
    final int duration = DateTime.now().difference(_sessionStart!).inMinutes;

    await FirebaseFirestore.instance
        .collection('user_sessions')
        .doc(_sessionId)
        .update({
      'exitScreen': newScreenTitle,
      'lastActive': FieldValue.serverTimestamp(),
      'durationMinutes': duration,
    });
  }
}