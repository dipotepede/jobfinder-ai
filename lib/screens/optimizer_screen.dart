import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/candidate_provider.dart';
import '../providers/diagnostic_provider.dart';

class ResumeOptimizerScreen extends ConsumerWidget {
  const ResumeOptimizerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candidate = ref.watch(candidateProvider);
    final diagnostic = ref.watch(diagnosticProvider);

    // Dynamic keyword suggestions based on identified gaps
    final List<Map<String, String>> optimizations = [
      {
        'category': 'Keyword Injection',
        'issue': 'Missing core framework references for ${candidate.targetJobTitle.isEmpty ? "Target Role" : candidate.targetJobTitle}.',
        'suggestion': 'Incorporate high-impact terms: ${diagnostic.criticalGaps.isNotEmpty ? diagnostic.criticalGaps.first : "Process Optimization, Requirements Engineering"}.',
      },
      {
        'category': 'Bullet Point Enhancement',
        'issue': 'Experience statements lack quantifiable metrics.',
        'suggestion': 'Transform "Responsible for process analysis" to "Spearheaded DMAIC process optimization, reducing operational cycle time by 18%."',
      },
      {
        'category': 'ATS Formatting Check',
        'issue': 'Section headers require standard parsing structure.',
        'suggestion': 'Ensure headers explicitly match standard ATS categories: "Professional Summary", "Core Competencies", "Technical Skills".',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Resume Optimization Matrix',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrangeAccent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Target Role: ${candidate.targetJobTitle.isEmpty ? "Unspecified" : candidate.targetJobTitle} (${candidate.experienceLevel})',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),

          // ATS Health Summary
          Card(
            color: Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMetricTile('Keyword Match', '${(diagnostic.overallMatchScore * 0.9).toInt()}%', Colors.orange),
                  _buildMetricTile('Formatting', '92%', Colors.green),
                  _buildMetricTile('Impact Score', '${(diagnostic.overallMatchScore * 0.85).toInt()}%', Colors.blue),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Actionable Optimization Recommendations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // List of Optimizations
          ...optimizations.map((item) => _buildOptimizationCard(context, item)),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildOptimizationCard(BuildContext context, Map<String, String> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: Colors.black45,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.white12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(
                    item['category']!,
                    style: const TextStyle(fontSize: 11, color: Colors.white),
                  ),
                  backgroundColor: Colors.deepOrange.withOpacity(0.8),
                  padding: EdgeInsets.zero,
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                  tooltip: 'Copy Suggestion',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: item['suggestion']!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Suggestion copied to clipboard!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item['issue']!,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Suggested Fix: ${item['suggestion']!}',
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}