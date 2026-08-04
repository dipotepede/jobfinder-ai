import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/candidate_provider.dart';
import '../providers/diagnostic_provider.dart';
import '../services/scholarship_aggregator_service.dart';

// --- SCHOLARSHIP DATA MODEL ---
class ScholarshipPosting {
  final String id;
  final String title;
  final String organization;
  final String coverage; // Full Funding, Partial, Research Grant
  final String type; // MSc, PhD, Fellowship
  final String deadline;
  final List<String> tags;
  final int eligibilityScore;
  final String description;
  final String applyUrl;

  const ScholarshipPosting({
    required this.id,
    required this.title,
    required this.organization,
    required this.coverage,
    required this.type,
    required this.deadline,
    required this.tags,
    required this.eligibilityScore,
    required this.description,
    required this.applyUrl,
  });
}

class ScholarshipsScreen extends ConsumerStatefulWidget {
  const ScholarshipsScreen({super.key});

  @override
  ConsumerState<ScholarshipsScreen> createState() => _ScholarshipsScreenState();
}

class _ScholarshipsScreenState extends ConsumerState<ScholarshipsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // All, Full Funding, MSc, PhD
  String _searchQuery = '';
  bool _isLoading = true;

  List<ScholarshipPosting> _scholarships = [];

  // Curated Baseline Global & Regional Grants
  final List<ScholarshipPosting> _baselineScholarships = const [
    ScholarshipPosting(
      id: 'sch_01',
      title: 'Commonwealth Shared Scholarships 2026/2027',
      organization: 'UK Commonwealth Scholarship Commission',
      coverage: 'Full Tuition + £1,347/mo Stipend + Airfare',
      type: 'MSc / Master\'s',
      deadline: 'December 2026',
      tags: ['UK', 'Full Funding', 'STEM', 'Developing Nations'],
      eligibilityScore: 96,
      description:
          'Targeted at high-achieving candidates from Commonwealth countries pursuing master\'s degrees in technology, engineering, and data science.',
      applyUrl: 'https://cscuk.fcdo.gov.uk/scholarships/commonwealth-shared-scholarships/',
    ),
    ScholarshipPosting(
      id: 'sch_02',
      title: 'Chevening International Leadership Fellowship',
      organization: 'UK Foreign, Commonwealth & Development Office',
      coverage: 'Fully Funded Executive Program',
      type: 'Fellowship',
      deadline: 'November 2026',
      tags: ['Leadership', 'Networking', 'Fully Funded', 'Global'],
      eligibilityScore: 93,
      description:
          'Prestigious global award for mid-career professionals demonstrating leadership potential and operational impact.',
      applyUrl: 'https://www.chevening.org/',
    ),
    ScholarshipPosting(
      id: 'sch_03',
      title: 'DAAD Doctoral Research Grants in Germany',
      organization: 'German Academic Exchange Service (DAAD)',
      coverage: '€1,300/mo Stipend + Health Insurance',
      type: 'PhD',
      deadline: 'October 2026',
      tags: ['Germany', 'PhD', 'Research Grant', 'Machine Learning'],
      eligibilityScore: 89,
      description:
          'Funding for doctoral candidates conducting advanced research in process engineering, artificial intelligence, and diagnostic modeling.',
      applyUrl: 'https://www.daad.de/en/',
    ),
    ScholarshipPosting(
      id: 'sch_04',
      title: 'PTDF Overseas Post-Graduate Scholarship',
      organization: 'Petroleum Technology Development Fund (Nigeria)',
      coverage: 'Full Tuition + Bench Fees + Living Allowance',
      type: 'MSc / PhD',
      deadline: 'January 2027',
      tags: ['Nigeria', 'Overseas', 'Energy & Data', 'PTDF'],
      eligibilityScore: 91,
      description:
          'National competitive scholarship scheme for Nigerian scholars pursuing specialized postgraduate degrees in top UK, French, and German institutions.',
      applyUrl: 'https://ptdf.gov.ng/',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _syncLiveScholarshipAggregator();
  }

  Future<void> _syncLiveScholarshipAggregator() async {
    setState(() => _isLoading = true);
    final liveResults = await ScholarshipAggregatorService.fetchLiveScholarships();

    if (mounted) {
      setState(() {
        _scholarships = [..._baselineScholarships, ...liveResults];
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Launching scholarship portal..."),
            backgroundColor: Colors.deepOrange,
          ),
        );
      }
    }
  }

  List<ScholarshipPosting> get _filteredScholarships {
    return _scholarships.where((item) {
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.organization.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));

      if (_selectedFilter == 'Full Funding') {
        return matchesSearch && item.coverage.toLowerCase().contains('full');
      } else if (_selectedFilter == 'MSc') {
        return matchesSearch && item.type.contains('MSc');
      } else if (_selectedFilter == 'PhD') {
        return matchesSearch && item.type.contains('PhD');
      }
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(candidateProvider);
    final diagnostic = ref.watch(diagnosticProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Header
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
                  'SCREEN 4 OF 9 — LIVE GLOBAL SCHOLARSHIP AGGREGATOR',
                  style: TextStyle(
                    color: Colors.deepOrangeAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Global Scholarships & Research Grants',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Candidate Background: ${candidate.fullName.isEmpty ? "Registered Candidate" : candidate.fullName} | Eligibility Index: ${diagnostic.overallMatchScore.toInt()}%',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.deepOrangeAccent),
                    onPressed: _syncLiveScholarshipAggregator,
                    tooltip: "Sync Live Scholarship API Feeds",
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Search & Filter Pill Bar
              Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: "Search scholarships by country, field (e.g. STEM, PhD), or sponsor...",
                          hintStyle: const TextStyle(color: Colors.white38),
                          prefixIcon: const Icon(Icons.school, color: Colors.deepOrangeAccent),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF404040))),
                          focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrangeAccent)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All'),
                            const SizedBox(width: 8),
                            _buildFilterChip('Full Funding'),
                            const SizedBox(width: 8),
                            _buildFilterChip('MSc'),
                            const SizedBox(width: 8),
                            _buildFilterChip('PhD'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Loading or Content Display
              if (_isLoading)
                Container(
                  padding: const EdgeInsets.all(40),
                  alignment: Alignment.center,
                  child: const Column(
                    children: [
                      CircularProgressIndicator(color: Colors.deepOrange),
                      SizedBox(height: 12),
                      Text("Aggregating Live International Fellowships & Research Grants...", style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                )
              else if (_filteredScholarships.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: const Text("No scholarship listings match your search criteria.", style: TextStyle(color: Colors.white54, fontSize: 14)),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredScholarships.length,
                  itemBuilder: (context, index) {
                    final item = _filteredScholarships[index];
                    return _buildScholarshipCard(item);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.deepOrange,
      backgroundColor: const Color(0xFF141414),
      onSelected: (bool selected) {
        if (selected) {
          setState(() => _selectedFilter = label);
        }
      },
    );
  }

  Widget _buildScholarshipCard(ScholarshipPosting item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: item.eligibilityScore >= 90 ? Colors.greenAccent.withValues(alpha: 0.4) : Colors.white12,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${item.organization} • Deadline: ${item.deadline}",
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: item.eligibilityScore >= 90 ? Colors.green.withValues(alpha: 0.2) : Colors.deepOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: item.eligibilityScore >= 90 ? Colors.greenAccent : Colors.deepOrangeAccent),
                    ),
                    child: Text(
                      "${item.eligibilityScore}% ELIGIBILITY",
                      style: TextStyle(
                        color: item.eligibilityScore >= 90 ? Colors.greenAccent : Colors.deepOrangeAccent,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                item.description,
                style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 14),

              // Coverage details
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.card_giftcard, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Funding: ${item.coverage}",
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Tags
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: item.tags
                          .map(
                            (tag) => Chip(
                              label: Text(tag, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                              backgroundColor: const Color(0xFF141414),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Divider(color: Colors.white12),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _launchUrl(item.applyUrl),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.open_in_new, color: Colors.white, size: 16),
                  label: const Text(
                    "Apply via Official Grant / University Portal",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}