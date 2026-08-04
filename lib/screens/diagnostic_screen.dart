import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/candidate_provider.dart';
import '../providers/diagnostic_provider.dart';

class UnifiedAISuiteScreen extends ConsumerStatefulWidget {
  const UnifiedAISuiteScreen({super.key});

  @override
  ConsumerState<UnifiedAISuiteScreen> createState() => _UnifiedAISuiteScreenState();
}

class _UnifiedAISuiteScreenState extends ConsumerState<UnifiedAISuiteScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _bulletController = TextEditingController(
    text: "Managed files and trained students in project management at local center.",
  );
  
  String _optimizedOutput = "";
  bool _isOptimizing = false;

  // Diagnostic Quiz State
  int _selectedQ1 = 0;
  int _selectedQ2 = 0;

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

  void _runCvOptimization() {
    setState(() => _isOptimizing = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isOptimizing = false;
          _optimizedOutput =
              "• Directed project management workflows for 200+ candidates, applying PMI standards to increase sprint task completion by 28%.\n"
              "• Spearheaded candidate diagnostic analytics using structured Python data pipelines with 99% accuracy.";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(candidateProvider);
    final diagnostic = ref.watch(diagnosticProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Badge Indicator
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
                  'SCREEN 2 OF 9 — ASSESSMENT & PREP',
                  style: TextStyle(
                    color: Colors.deepOrangeAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Screen Title Header
              Text(
                'Unified AI Suite (Diagnostic + Radar + Optimizer)',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Candidate Profile: ${candidate.fullName.isEmpty ? "Registered Candidate" : candidate.fullName} | Focus: ${candidate.targetJobTitle.isEmpty ? "Target Role" : candidate.targetJobTitle}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Tab Controller Bar
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
                    Tab(text: "⚡ Adaptive AI Diagnostic"),
                    Tab(text: "📊 Competency Radar"),
                    Tab(text: "📝 CV Optimizer"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab View Content Container
              SizedBox(
                height: 680,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDiagnosticTab(diagnostic),
                    _buildRadarTab(diagnostic),
                    _buildOptimizerTab(candidate, diagnostic),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 1: ADAPTIVE AI DIAGNOSTIC ---
  Widget _buildDiagnosticTab(dynamic result) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
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
                  const Text(
                    "Low-Bandwidth Diagnostic Assessment",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Question 1
                  const Text(
                    "1. Data Logic: In a process baseline recording 450 DPMO, what does a +1.5 Sigma shift indicate?",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<int>(
                    value: 0,
                    groupValue: _selectedQ1,
                    activeColor: Colors.deepOrange,
                    title: const Text("Process mean shift relative to specification limits", style: TextStyle(color: Colors.white, fontSize: 13)),
                    onChanged: (val) => setState(() => _selectedQ1 = val!),
                  ),
                  RadioListTile<int>(
                    value: 1,
                    groupValue: _selectedQ1,
                    activeColor: Colors.deepOrange,
                    title: const Text("Process variability expanded by 50%", style: TextStyle(color: Colors.white, fontSize: 13)),
                    onChanged: (val) => setState(() => _selectedQ1 = val!),
                  ),
                  const SizedBox(height: 16),

                  // Question 2
                  const Text(
                    "2. AI Prompting: Which setup provides high-precision structured evaluation outputs?",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  RadioListTile<int>(
                    value: 0,
                    groupValue: _selectedQ2,
                    activeColor: Colors.deepOrange,
                    title: const Text("JSON schema output with system instruction boundaries", style: TextStyle(color: Colors.white, fontSize: 13)),
                    onChanged: (val) => setState(() => _selectedQ2 = val!),
                  ),
                  RadioListTile<int>(
                    value: 1,
                    groupValue: _selectedQ2,
                    activeColor: Colors.deepOrange,
                    title: const Text("Unstructured descriptive narrative", style: TextStyle(color: Colors.white, fontSize: 13)),
                    onChanged: (val) => setState(() => _selectedQ2 = val!),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Diagnostic Evaluated! Check Competency Radar tab."),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _tabController.animateTo(1);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text("Evaluate Capabilities & Generate Benchmark Score", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 2: COMPETENCY RADAR ---
  Widget _buildRadarTab(dynamic result) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
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
                  // Metric Box
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                      border: const Border(left: BorderSide(color: Colors.deepOrange, width: 4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Employability Benchmark Index", style: TextStyle(color: Colors.white70, fontSize: 13)),
                            SizedBox(height: 4),
                            Text("82 / 100", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Text("+24% vs Regional", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Skill Progress Bars
                  const Text("Data Literacy & Logic: 88%", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  const LinearProgressIndicator(value: 0.88, color: Colors.deepOrange, backgroundColor: Colors.white12),
                  const SizedBox(height: 16),

                  const Text("AI Prompt Governance: 76%", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  const LinearProgressIndicator(value: 0.76, color: Colors.deepOrange, backgroundColor: Colors.white12),
                  const SizedBox(height: 16),

                  const Text("ATS Optimization Level: 58%", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 6),
                  const LinearProgressIndicator(value: 0.58, color: Colors.amber, backgroundColor: Colors.white12),
                  const SizedBox(height: 24),

                  // Radar Chart
                  SizedBox(
                    height: 220,
                    child: RadarChart(
                      RadarChartData(
                        radarShape: RadarShape.polygon,
                        ticksTextStyle: const TextStyle(color: Colors.transparent),
                        gridBorderData: const BorderSide(color: Colors.white24, width: 1),
                        titlePositionPercentageOffset: 0.2,
                        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 11),
                        getTitle: (index, angle) {
                          switch (index) {
                            case 0:
                              return const RadarChartTitle(text: 'Technical');
                            case 1:
                              return const RadarChartTitle(text: 'Domain');
                            case 2:
                              return const RadarChartTitle(text: 'Analytical');
                            case 3:
                              return const RadarChartTitle(text: 'Tools');
                            case 4:
                              return const RadarChartTitle(text: 'Leadership');
                            default:
                              return const RadarChartTitle(text: '');
                          }
                        },
                        dataSets: [
                          RadarDataSet(
                            fillColor: Colors.blue.withValues(alpha: 0.3),
                            borderColor: Colors.blue,
                            entryRadius: 3,
                            dataEntries: [
                              RadarEntry(value: result.technicalSkill ?? 80),
                              RadarEntry(value: result.domainKnowledge ?? 75),
                              RadarEntry(value: result.analyticalCapability ?? 85),
                              RadarEntry(value: result.toolsMastery ?? 70),
                              RadarEntry(value: result.leadershipComm ?? 80),
                            ],
                          ),
                          RadarDataSet(
                            fillColor: Colors.deepOrange.withValues(alpha: 0.2),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 3: CV OPTIMIZER ---
  Widget _buildOptimizerTab(dynamic candidate, dynamic diagnostic) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
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
                  const Text(
                    "AI-Assisted Resume Restructuring Engine",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Transform raw candidate bullet points into metric-driven, ATS-optimized descriptions.",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _bulletController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Paste Raw Experience Bullet Point",
                      labelStyle: TextStyle(color: Colors.white70),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF404040))),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: _isOptimizing ? null : _runCvOptimization,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isOptimizing
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Run JOBFinder AI Optimization", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),

                  if (_optimizedOutput.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text("JOBFinder AI Restructured Output:", style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _optimizedOutput,
                              style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _optimizedOutput));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Optimized text copied!"), backgroundColor: Colors.green),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}