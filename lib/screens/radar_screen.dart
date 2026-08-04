import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/diagnostic_provider.dart';

class SkillBenchmarkRadarScreen extends ConsumerWidget {
  const SkillBenchmarkRadarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(diagnosticProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Competency vs. Market Benchmark',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepOrangeAccent,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Blue = Candidate Baseline | Orange = Target Industry Standard',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 20),

          // Radar Chart Display
          Expanded(
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                ticksTextStyle: const TextStyle(color: Colors.transparent),
                gridBorderData: const BorderSide(color: Colors.white24, width: 1),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle: const TextStyle(color: Colors.white, fontSize: 12),
                getTitle: (index, angle) {
                  switch (index) {
                    case 0:
                      return RadarChartTitle(text: 'Technical');
                    case 1:
                      return RadarChartTitle(text: 'Domain');
                    case 2:
                      return RadarChartTitle(text: 'Analytical');
                    case 3:
                      return RadarChartTitle(text: 'Tools');
                    case 4:
                      return RadarChartTitle(text: 'Leadership');
                    default:
                      return const RadarChartTitle(text: '');
                  }
                },
                dataSets: [
                  // Candidate Data Set
                  RadarDataSet(
                    fillColor: Colors.blue.withOpacity(0.3),
                    borderColor: Colors.blue,
                    entryRadius: 3,
                    dataEntries: [
                      RadarEntry(value: result.technicalSkill),
                      RadarEntry(value: result.domainKnowledge),
                      RadarEntry(value: result.analyticalCapability),
                      RadarEntry(value: result.toolsMastery),
                      RadarEntry(value: result.leadershipComm),
                    ],
                  ),
                  // Market Benchmark Data Set
                  RadarDataSet(
                    fillColor: Colors.deepOrange.withOpacity(0.2),
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
    );
  }
}