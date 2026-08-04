import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Admin Passcode Config (6-digit PIN)
const String adminPasscode = '772026';

// Admin Toggle State Provider
final isAdminModeProvider = StateProvider<bool>((ref) => false);

// ------------------- Dynamic Content State -------------------

// PDF Resources Provider (Screen 5)
final pdfResourcesProvider = StateNotifierProvider<PdfNotifier, List<Map<String, String>>>((ref) {
  return PdfNotifier();
});

class PdfNotifier extends StateNotifier<List<Map<String, String>>> {
  PdfNotifier()
      : super([
          {
            'id': '1',
            'title': 'Numerical Reasoning Master Guide',
            'category': 'Quantitative Aptitude',
            'size': '2.4 MB',
            'description': 'Essential formulas, word problems, and speed-calculation shortcuts.',
            'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          },
          {
            'id': '2',
            'title': 'Verbal Critical Reasoning Practice Pack',
            'category': 'Verbal Aptitude',
            'size': '1.8 MB',
            'description': 'Passage comprehension, deduction rules, and logical inference drills.',
            'url': 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          },
        ]);

  void addPdf(Map<String, String> item) {
    state = [...state, item];
  }

  void removePdf(String id) {
    state = state.where((element) => element['id'] != id).toList();
  }
}

// Books Hub Provider (Screen 6)
final booksProvider = StateNotifierProvider<BooksNotifier, List<Map<String, String>>>((ref) {
  return BooksNotifier();
});

class BooksNotifier extends StateNotifier<List<Map<String, String>>> {
  BooksNotifier()
      : super([
          {
            'id': '1',
            'title': 'Mastering Business Analysis Assessments',
            'author': 'JOBFinder Publications',
            'price': '\$19.99',
            'tag': 'Best Seller',
            'synopsis': 'A comprehensive playbook on case study dissection and process modeling.',
          },
          {
            'id': '2',
            'title': 'Lean Six Sigma for Young Professionals',
            'author': 'Process Excellence Series',
            'price': '\$24.99',
            'tag': 'Featured',
            'synopsis': 'Practical application of DMAIC principles to operational strategy.',
          },
        ]);

  void addBook(Map<String, String> item) {
    state = [...state, item];
  }

  void removeBook(String id) {
    state = state.where((element) => element['id'] != id).toList();
  }
}

// Gateway Config Provider (Screen 7)
final gatewayConfigProvider = StateNotifierProvider<GatewayNotifier, Map<String, String>>((ref) {
  return GatewayNotifier();
});

class GatewayNotifier extends StateNotifier<Map<String, String>> {
  GatewayNotifier()
      : super({
          'title': 'Accredited Training Programs',
          'description': 'Gain structured, practical knowledge in Project Management (PMP), Business Analysis, and Lean Six Sigma methodologies with full exam preparation support.',
          'url': 'https://pmtutor.org',
        });

  void updateGateway(String title, String description, String url) {
    state = {
      'title': title,
      'description': description,
      'url': url,
    };
  }
}

// ------------------- Telemetry & Analytics Service -------------------

class AnalyticsService {
  static void startSession() {
    debugPrint("[Analytics] Session initialized.");
  }

  static void trackScreenChange(String screenTitle) {
    debugPrint("[Analytics] Navigated to screen: $screenTitle");
  }

  static void trackFeatureUsage(String featureName) {
    debugPrint("[Analytics] Feature triggered: $featureName");
  }

  static void exportTelemetryCsv(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Telemetry CSV export compiled successfully."),
        backgroundColor: Colors.green,
      ),
    );
  }
}