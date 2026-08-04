import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/candidate_provider.dart';
import '../providers/diagnostic_provider.dart';
import '../services/gemini_service.dart';

class UnifiedAISuiteScreen extends ConsumerStatefulWidget {
  const UnifiedAISuiteScreen({super.key});

  @override
  ConsumerState<UnifiedAISuiteScreen> createState() =>
      _UnifiedAISuiteScreenState();
}

class _UnifiedAISuiteScreenState extends ConsumerState<UnifiedAISuiteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _bulletController = TextEditingController(
    text: "Tepede, D. Machine Learning Model for Anomaly-Based Intrusion Detection Using Random Forest Classifier",
  );

  String _optimizedOutput = "";
  bool _isOptimizing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bulletController.dispose();
    super.dispose();
  }

  void _runCvOptimization() async {
    setState(() => _isOptimizing = true);
    final candidate = ref.read(candidateProvider);

    final activeRole = candidate.targetJobTitle.isNotEmpty
        ? candidate.targetJobTitle
        : 'Senior Business Analyst / Project Consultant';

    final result = await GeminiService.optimizeBulletPoint(
      targetRole: activeRole,
      rawBullet: _bulletController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isOptimizing = false;
        _optimizedOutput = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(candidateProvider);
    final diagnostic = ref.watch(diagnosticProvider);

    final displayRole = candidate.targetJobTitle.isNotEmpty
        ? candidate.targetJobTitle
        : 'Senior Business Analyst / Project Consultant';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.deepOrange.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.deepOrange.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'SCREEN 2 OF 9 — DIAGNOSTIC & CV OPTIMIZER',
                  style: TextStyle(
                    color: Colors.deepOrangeAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Unified AI Suite',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Candidate: ${candidate.fullName.isEmpty ? "Dipo Tepede" : candidate.fullName} | Evaluated Level: $displayRole',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Tabs
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.deepOrangeAccent,
                  indicatorWeight: 3,
                  labelColor: Colors.deepOrangeAccent,
                  unselectedLabelColor: Colors.white70,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: "⚡ Strengths & Job Match"),
                    Tab(text: "📊 Competency Radar"),
                    Tab(text: "📝 Comprehensive CV Optimizer"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 820,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDiagnosticTab(candidate, diagnostic, displayRole),
                    _buildRadarTab(diagnostic),
                    _buildOptimizerTab(candidate, diagnostic, displayRole),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 1: DIAGNOSTIC (STRENGTHS, WEAKNESSES, RECOMMENDED JOBS) ---
  Widget _buildDiagnosticTab(dynamic candidate, DiagnosticState diagnostic, String displayRole) {
    return SingleChildScrollView(
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.deepOrange.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "AI Candidate Audit & Placement Diagnostics",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  ElevatedButton.icon(
                    onPressed: diagnostic.isLoading
                        ? null
                        : () async {
                            await ref.read(diagnosticProvider.notifier).runLiveGeminiDiagnostic(
                                  targetRole: displayRole,
                                  resumeText: candidate.resumeText.isEmpty
                                      ? 'DIPO TEPEDE, MSc, PMP, ICBB, Lead Consultant & Trainer'
                                      : candidate.resumeText,
                                );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.analytics, color: Colors.white, size: 18),
                    label: diagnostic.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text("Run Full Diagnostic", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (!diagnostic.isEvaluated && !diagnostic.isLoading)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Text(
                    "Tap 'Run Full Diagnostic' above to trigger Gemini analysis of your target credentials, strengths, gaps, and recommended job roles.",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),

              if (diagnostic.isEvaluated) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141414),
                    borderRadius: BorderRadius.circular(10),
                    border: const Border(left: BorderSide(color: Colors.deepOrange, width: 4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Overall Profile Benchmark Score: ${diagnostic.overallMatchScore.toInt()}%",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const Chip(
                            label: Text("DIAGNOSTIC COMPLETE", style: TextStyle(color: Colors.greenAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                            backgroundColor: Colors.black54,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text("Recommended Target Job Titles:", style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      ...diagnostic.recommendedJobs.map((job) => Text("• $job", style: const TextStyle(color: Colors.white, fontSize: 13))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                const Text("Identified Key Strengths:", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                ...diagnostic.strengths.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 13))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text("Critical Profile Gaps & Action Items:", style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                ...diagnostic.weaknesses.map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.amberAccent, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(w, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 2: COMPETENCY RADAR WITH EXPLICIT METRIC BREAKDOWN ---
  Widget _buildRadarTab(DiagnosticState diagnostic) {
    final techScore = diagnostic.technicalSkill == 0 ? 85.0 : diagnostic.technicalSkill;
    final domainScore = diagnostic.domainKnowledge == 0 ? 88.0 : diagnostic.domainKnowledge;
    final analyticalScore = diagnostic.analyticalCapability == 0 ? 92.0 : diagnostic.analyticalCapability;
    final toolsScore = diagnostic.toolsMastery == 0 ? 80.0 : diagnostic.toolsMastery;
    final leadershipScore = diagnostic.leadershipComm == 0 ? 88.0 : diagnostic.leadershipComm;

    return SingleChildScrollView(
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.deepOrange.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Competency Benchmark Radar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 4),
              const Text("Blue = Candidate Profile Score | Orange = Target Industry Standard (85%)", style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 20),

              // Radar Chart Graphic
              SizedBox(
                height: 240,
                child: RadarChart(
                  RadarChartData(
                    radarShape: RadarShape.polygon,
                    ticksTextStyle: const TextStyle(color: Colors.transparent),
                    gridBorderData: const BorderSide(color: Colors.white24, width: 1),
                    titlePositionPercentageOffset: 0.2,
                    titleTextStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    getTitle: (index, angle) {
                      switch (index) {
                        case 0: return const RadarChartTitle(text: 'Technical');
                        case 1: return const RadarChartTitle(text: 'Domain');
                        case 2: return const RadarChartTitle(text: 'Analytical');
                        case 3: return const RadarChartTitle(text: 'Tools');
                        case 4: return const RadarChartTitle(text: 'Leadership');
                        default: return const RadarChartTitle(text: '');
                      }
                    },
                    dataSets: [
                      RadarDataSet(
                        fillColor: Colors.blue.withValues(alpha: 0.3),
                        borderColor: Colors.blue,
                        entryRadius: 4,
                        dataEntries: [
                          RadarEntry(value: techScore),
                          RadarEntry(value: domainScore),
                          RadarEntry(value: analyticalScore),
                          RadarEntry(value: toolsScore),
                          RadarEntry(value: leadershipScore),
                        ],
                      ),
                      RadarDataSet(
                        fillColor: Colors.deepOrange.withValues(alpha: 0.15),
                        borderColor: Colors.deepOrange,
                        entryRadius: 3,
                        dataEntries: const [
                          RadarEntry(value: 85.0),
                          RadarEntry(value: 80.0),
                          RadarEntry(value: 90.0),
                          RadarEntry(value: 85.0),
                          RadarEntry(value: 75.0),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // EXPLICIT METRIC EXPLANATION MATRIX
              const Text("Detailed Competency Audit Matrix:", style: TextStyle(color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 12),

              _buildCompetencyRow("Technical Execution", techScore, "Evaluates proficiency in machine learning, model validation, and deployment pipelines."),
              _buildCompetencyRow("Domain Knowledge", domainScore, "Measures alignment with industry methodologies, governance, and business systems."),
              _buildCompetencyRow("Analytical Capability", analyticalScore, "Assesses root cause analysis, statistical reasoning, and data-driven problem solving."),
              _buildCompetencyRow("Tools Mastery", toolsScore, "Reflects hands-on experience with high-performance tools (Python, PyTorch, Minitab, GCP)."),
              _buildCompetencyRow("Leadership & Strategy", leadershipScore, "Evaluates project governance, stakeholder communication, and continuous improvement (Kaizen)."),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompetencyRow(String category, double score, String explanation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Text("${score.toInt()}% Match", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 4),
            Text(explanation, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // --- TAB 3: EXPANDED COMPREHENSIVE CV OPTIMIZER ---
  Widget _buildOptimizerTab(dynamic candidate, DiagnosticState diagnostic, String displayRole) {
    return SingleChildScrollView(
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.deepOrange.withValues(alpha: 0.3)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("AI Executive Resume & Publication Restructuring Engine", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text("Optimizing for Target Role: $displayRole", style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 16),

              TextFormField(
                controller: _bulletController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: "Paste Raw Experience Bullet Point, Research Paper Title, or Job Summary",
                  labelStyle: TextStyle(color: Colors.white70),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF404040))),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _isOptimizing ? null : _runCvOptimization,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.auto_fix_high, color: Colors.white),
                  label: _isOptimizing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Run Complete Executive Restructure", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),

              if (_optimizedOutput.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("JOBFinder AI Comprehensive Restructure:", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _optimizedOutput));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Restructured report copied to clipboard!"), backgroundColor: Colors.green),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    _optimizedOutput,
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}