import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

// Import App Screens & Providers
import 'screens/auth_screen.dart';
import 'providers/admin_provider.dart'; // Exports AnalyticsService
import 'screens/onboarding_screen.dart';
import 'screens/unified_ai_suite_screen.dart';
import 'screens/jobs_screen.dart';
import 'screens/scholarships_screen.dart';
import 'screens/pdf_screen.dart';
import 'screens/books_screen.dart';
import 'screens/gateway_screen.dart';
import 'screens/admin_telemetry_screen.dart';
import 'screens/contact_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: JobFinderAIApp()));
}

class JobFinderAIApp extends StatelessWidget {
  const JobFinderAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JOBFinder AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        useMaterial3: true,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Colors.deepOrange),
              ),
            );
          }
          if (snapshot.hasData) {
            AnalyticsService.startSession();
            return const MainNavigationShell();
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({super.key});

  static const List<Widget> _screens = [
    CandidateOnboardingScreen(),  // Screen 1: Candidate Intake
    UnifiedAISuiteScreen(),       // Screen 2: Unified AI Suite
    JobBoardScreen(),             // Screen 3: Nigeria & Remote Jobs Board
    ScholarshipsScreen(),         // Screen 4: Global Scholarships & Grants
    FreeAptitudePdfScreen(),      // Screen 5: Past Questions Test PDFs
    BooksHubScreen(),             // Screen 6: Career eBook Shop
    PmTutorGatewayScreen(),       // Screen 7: Training Portal Gateway
    ContactProcurementScreen(),   // Screen 8: Checkout & Banking Info
    AdminTelemetryScreen(),       // Screen 9: Admin Control Panel
  ];

  static const List<String> _screenTitles = [
    'Screen 1: Candidate Intake',
    'Screen 2: Unified AI Suite',
    'Screen 3: Nigeria & Remote Jobs Board',
    'Screen 4: Global Scholarships & Grants',
    'Screen 5: Free Aptitude Test PDFs',
    'Screen 6: JOBFinder Books Hub',
    'Screen 7: PMtutor Training Gateway',
    'Screen 8: Procurement & Banking Contact',
    'Screen 9: Admin Control Panel',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            ),
          );
        }

        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final String userRole = userData?['role'] ?? 'candidate';
        final bool isAdminMode = (userRole == 'admin');

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _screenTitles[selectedIndex < _screenTitles.length ? selectedIndex : 0],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            backgroundColor: isAdminMode ? const Color(0xFF1E1010) : const Color(0xFF1A1A1A),
            elevation: isAdminMode ? 4 : 0,
            actions: [
              if (isAdminMode)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Chip(
                    avatar: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 16),
                    label: const Text(
                      'ADMIN MODE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.logout),
                tooltip: 'Sign Out',
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
              ),
            ],
          ),
          drawer: Drawer(
            backgroundColor: const Color(0xFF1E1E1E),
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: isAdminMode ? const Color(0xFF2B1515) : Colors.deepOrange,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'JOBFinder AI',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: isAdminMode
                              ? [const Shadow(color: Colors.redAccent, blurRadius: 10)]
                              : [],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userData?['fullName'] ?? user?.email ?? 'User',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAdminMode
                            ? 'Mode: System Administrator'
                            : 'Mode: Candidate / End-User',
                        style: TextStyle(
                          color: isAdminMode ? Colors.amberAccent : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Drawer Navigation Links
                for (int i = 0; i < _screens.length; i++)
                  if (i != 8 || isAdminMode) // Screen 9 restricted to Admins
                    ListTile(
                      title: Text(
                        _screenTitles[i],
                        style: TextStyle(
                          color: selectedIndex == i
                              ? Colors.deepOrangeAccent
                              : Colors.white70,
                          fontWeight: selectedIndex == i
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      selected: selectedIndex == i,
                      selectedTileColor: isAdminMode
                          ? Colors.redAccent.withValues(alpha: 0.2)
                          : Colors.deepOrange.withValues(alpha: 0.2),
                      onTap: () {
                        ref.read(selectedIndexProvider.notifier).state = i;
                        AnalyticsService.trackScreenChange(_screenTitles[i]);
                        Navigator.pop(context);
                      },
                    ),
              ],
            ),
          ),
          body: Container(
            decoration: isAdminMode
                ? BoxDecoration(
                    border: Border.all(
                      color: Colors.redAccent.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  )
                : null,
            child: _screens[selectedIndex < _screens.length ? selectedIndex : 0],
          ),
        );
      },
    );
  }
}