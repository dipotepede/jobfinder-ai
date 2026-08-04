import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/candidate_provider.dart';
import '../providers/diagnostic_provider.dart';
import '../services/job_aggregator_service.dart';

// --- JOB DATA MODEL ---
class JobPosting {
  final String id;
  final String title;
  final String company;
  final String location;
  final String type; // Remote, Hybrid, On-site
  final String salary;
  final List<String> tags;
  final int matchScore;
  final String description;
  final String applyUrl;

  const JobPosting({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.salary,
    required this.tags,
    required this.matchScore,
    required this.description,
    required this.applyUrl,
  });

  factory JobPosting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return JobPosting(
      id: doc.id,
      title: data['title'] ?? 'Untitled Position',
      company: data['company'] ?? 'Enterprise Partner',
      location: data['location'] ?? 'Remote / Nigeria',
      type: data['type'] ?? 'Remote',
      salary: data['salary'] ?? 'Competitive',
      tags: List<String>.from(data['tags'] ?? []),
      matchScore: (data['matchScore'] ?? 85) as int,
      description: data['description'] ?? 'No description provided.',
      applyUrl: data['applyUrl'] ?? 'https://google.com',
    );
  }
}

// --- RIVERPOD STREAM PROVIDER FOR LIVE FIRESTORE JOBS ---
final liveJobsStreamProvider = StreamProvider<List<JobPosting>>((ref) {
  return FirebaseFirestore.instance
      .collection('jobs')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => JobPosting.fromFirestore(doc)).toList(),
      );
});

class JobBoardScreen extends ConsumerStatefulWidget {
  const JobBoardScreen({super.key});

  @override
  ConsumerState<JobBoardScreen> createState() => _JobBoardScreenState();
}

class _JobBoardScreenState extends ConsumerState<JobBoardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // All, Remote, Nigeria, Hybrid
  String _searchQuery = '';
  List<JobPosting> _aggregatedApiJobs = [];
  bool _isAggregatorSyncing = false;

  // --- 10 EXPANDED CORPORATE TECHNICAL BASELINE ROLES ---
  final List<JobPosting> _localJobs = const [
    JobPosting(
      id: 'job_01',
      title: 'Senior Business Systems Analyst',
      company: 'Interswitch Group',
      location: 'Lagos, Nigeria (Hybrid)',
      type: 'Hybrid',
      salary: '₦12M - ₦18M / yr',
      tags: ['Process Modeling', 'SQL', 'BPMN', 'CBAP'],
      matchScore: 95,
      description:
          'Drive business requirement gathering, workflow modeling, and API integration specifications for enterprise payment gateways.',
      applyUrl: 'https://interswitchgroup.com/careers',
    ),
    JobPosting(
      id: 'job_02',
      title: 'Lead Technical Project Manager (PMO)',
      company: 'Paystack / Stripe',
      location: 'Lagos / Remote',
      type: 'Remote',
      salary: '\$50,000 - \$70,000 / yr',
      tags: ['PMP', 'Agile/Scrum', 'Jira', 'API Architecture'],
      matchScore: 92,
      description:
          'Oversee cross-functional engineering teams executing scalable fintech infrastructure products across African corridors.',
      applyUrl: 'https://paystack.com/careers',
    ),
    JobPosting(
      id: 'job_03',
      title: 'AI Pipeline & Quality Governance Lead',
      company: 'OmniRetail Africa',
      location: 'Lagos, Nigeria',
      type: 'On-site',
      salary: '₦10M - ₦15M / yr',
      tags: ['PyTorch', 'Model Validation', 'Minitab', 'GCP'],
      matchScore: 90,
      description:
          'Govern computer vision models, SPC charts, and inventory diagnostic pipelines deployed in supply chain environments.',
      applyUrl: 'https://omniretail.africa/careers',
    ),
    JobPosting(
      id: 'job_04',
      title: 'Senior Mobile Systems Engineer (Flutter/Dart)',
      company: 'Kuda Bank',
      location: 'Lagos, Nigeria (Hybrid)',
      type: 'Hybrid',
      salary: '₦14M - ₦20M / yr',
      tags: ['Flutter', 'Dart', 'Firestore', 'State Management'],
      matchScore: 89,
      description:
          'Architect modular Flutter applications, optimize state management pipelines, and build robust admin telemetry screens.',
      applyUrl: 'https://kuda.com/careers',
    ),
    JobPosting(
      id: 'job_05',
      title: 'Continuous Improvement Manager (LSS Black Belt)',
      company: 'Dangote Group',
      location: 'Lagos, Nigeria',
      type: 'On-site',
      salary: '₦16M - ₦24M / yr',
      tags: ['Lean Six Sigma', 'DMAIC', 'RCA', 'DOE'],
      matchScore: 88,
      description:
          'Lead plant-wide DMAIC initiatives, execute Factorial DOE experiments, and reduce process variance across operations.',
      applyUrl: 'https://dangote.com/careers',
    ),
    JobPosting(
      id: 'job_06',
      title: 'Principal Cloud DevOps Architect',
      company: 'Toptal',
      location: 'Global Remote',
      type: 'Remote',
      salary: '\$80,000 - \$110,000 / yr',
      tags: ['GCP', 'Docker', 'Kubernetes', 'CI/CD Pipelines'],
      matchScore: 87,
      description:
          'Design and govern automated deployment pipelines, cloud CDN distribution, and edge hosting microservices globally.',
      applyUrl: 'https://toptal.com/careers',
    ),
    JobPosting(
      id: 'job_07',
      title: 'Senior Enterprise Data Analyst',
      company: 'MTN Nigeria',
      location: 'Lagos, Nigeria (Hybrid)',
      type: 'Hybrid',
      salary: '₦11M - ₦16M / yr',
      tags: ['Python', 'Pandas', 'PowerBI', 'Statistical Modeling'],
      matchScore: 86,
      description:
          'Extract actionable intelligence from high-volume transaction datasets to optimize subscriber lifecycle retention metrics.',
      applyUrl: 'https://mtn.ng/careers',
    ),
    JobPosting(
      id: 'job_08',
      title: 'Lead Product Manager (Platform Services)',
      company: 'Moniepoint Microfinance Bank',
      location: 'Lagos, Nigeria',
      type: 'On-site',
      salary: '₦15M - ₦22M / yr',
      tags: ['Product Backlog', 'Agile Governance', 'Roadmapping'],
      matchScore: 85,
      description:
          'Define core requirements, operational workflows, and release cycles for merchant acquisition platform engines.',
      applyUrl: 'https://moniepoint.com/careers',
    ),
    JobPosting(
      id: 'job_09',
      title: 'Machine Learning Infrastructure Engineer',
      company: 'Andela',
      location: 'Global Remote',
      type: 'Remote',
      salary: '\$65,000 - \$90,000 / yr',
      tags: ['PyTorch', 'MobileNetV2', 'Python', 'MLOps'],
      matchScore: 84,
      description:
          'Deploy optimized deep learning diagnostic models on edge devices, maintaining architectural integrity and feature extraction.',
      applyUrl: 'https://andela.com/careers',
    ),
    JobPosting(
      id: 'job_10',
      title: 'Head of Quality Assurance & Operations',
      company: 'Flutterwave',
      location: 'Lagos / Remote',
      type: 'Remote',
      salary: '\$55,000 - \$75,000 / yr',
      tags: ['Quality Governance', 'SPC Control Charts', 'Automation'],
      matchScore: 83,
      description:
          'Establish statistical process control (i-mR chart monitoring) across core platform infrastructure to enforce SLA operational standards.',
      applyUrl: 'https://flutterwave.com/careers',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchExternalApiJobs();
  }

  Future<void> _fetchExternalApiJobs() async {
    setState(() => _isAggregatorSyncing = true);
    try {
      final liveResults = await JobAggregatorService.fetchLiveJobs();
      if (mounted) {
        setState(() {
          _aggregatedApiJobs = liveResults;
          _isAggregatorSyncing = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isAggregatorSyncing = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchApplyUrl(String urlString, String company) async {
    final Uri uri = Uri.parse(urlString);
    try {
      final success = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
        webOnlyWindowName: '_blank',
      );
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Could not launch application link for $company."),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Redirecting to $company application page..."),
            backgroundColor: Colors.deepOrange,
          ),
        );
      }
    }
  }

  List<JobPosting> _applyFilters(List<JobPosting> allJobs) {
    return allJobs.where((job) {
      // 1. HARD PURGE: Drop non-job blog items / zero-salary RSS feeds
      final titleLower = job.title.toLowerCase();
      final companyLower = job.company.toLowerCase();
      final salaryClean = job.salary.replaceAll(RegExp(r'\s+'), '');

      final isMockArticle =
          titleLower.contains('failure breeds') ||
          titleLower.contains('put the effort') ||
          companyLower.contains('deliberate development');

      final isZeroSalary =
          salaryClean.contains('0-0') ||
          salaryClean.contains('\$0-\$0') ||
          salaryClean == '0/yr';

      if (isMockArticle || isZeroSalary) {
        return false;
      }

      // 2. Search & Location Filters
      final matchesSearch =
          job.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.company.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          job.tags.any(
            (t) => t.toLowerCase().contains(_searchQuery.toLowerCase()),
          );

      if (_selectedFilter == 'Remote') {
        return matchesSearch && job.type == 'Remote';
      } else if (_selectedFilter == 'Nigeria') {
        return matchesSearch && job.location.contains('Nigeria');
      } else if (_selectedFilter == 'Hybrid') {
        return matchesSearch && job.type == 'Hybrid';
      }
      return matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(candidateProvider);
    final diagnostic = ref.watch(diagnosticProvider);
    final firestoreJobsAsync = ref.watch(liveJobsStreamProvider);

    return SafeArea(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 950),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.deepOrange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.deepOrange.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    'SCREEN 3 OF 9 — LIVE FIRESTORE & AGGREGATOR ENGINE',
                    style: TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Nigeria & Global Remote Vacancies',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Target Alignment: ${candidate.targetJobTitle.isEmpty ? "All Technical Roles" : candidate.targetJobTitle} | Profile Score: ${diagnostic.overallMatchScore.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: _isAggregatorSyncing
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.deepOrangeAccent,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.refresh,
                              color: Colors.deepOrangeAccent,
                            ),
                      onPressed: _fetchExternalApiJobs,
                      tooltip: "Sync External Job Streams",
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Search & Filter Card
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
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText:
                                "Search live postings by title, skill (e.g. DMAIC, Python), or company...",
                            hintStyle: const TextStyle(color: Colors.white38),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.deepOrangeAccent,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF404040)),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.deepOrangeAccent,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('All'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Remote'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Nigeria'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Hybrid'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Reactive Stream Feed
                firestoreJobsAsync.when(
                  data: (firestoreJobs) {
                    final Map<String, JobPosting> mergedMap = {};
                    for (var j in _localJobs) {
                      mergedMap[j.id] = j;
                    }
                    for (var j in _aggregatedApiJobs) {
                      mergedMap[j.id] = j;
                    }
                    for (var j in firestoreJobs) {
                      mergedMap[j.id] = j;
                    }

                    final filtered = _applyFilters(mergedMap.values.toList());

                    if (filtered.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: const Text(
                          "No vacancies matching your query. Adjust search keywords or refresh live feeds.",
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return _buildJobCard(filtered[index]);
                      },
                    );
                  },
                  loading: () => Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: const Column(
                      children: [
                        CircularProgressIndicator(color: Colors.deepOrange),
                        SizedBox(height: 12),
                        Text(
                          "Connecting to Cloud Firestore Live Job Stream...",
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  error: (err, stack) => Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.red.withValues(alpha: 0.1),
                    child: Text(
                      "Error loading Firestore job stream: $err",
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ],
            ),
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

  Widget _buildJobCard(JobPosting job) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: job.matchScore >= 90
              ? Colors.greenAccent.withValues(alpha: 0.4)
              : Colors.white12,
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
                        job.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${job.company} • ${job.location}",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: job.matchScore >= 90
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.deepOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: job.matchScore >= 90
                          ? Colors.greenAccent
                          : Colors.deepOrangeAccent,
                    ),
                  ),
                  child: Text(
                    "${job.matchScore}% MATCH",
                    style: TextStyle(
                      color: job.matchScore >= 90
                          ? Colors.greenAccent
                          : Colors.deepOrangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              job.description,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: job.tags
                        .map(
                          (tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                            backgroundColor: const Color(0xFF141414),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Text(
                  job.salary,
                  style: const TextStyle(
                    color: Colors.amberAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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
                onPressed: () => _launchApplyUrl(job.applyUrl, job.company),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.launch, color: Colors.white, size: 16),
                label: const Text(
                  "Apply Now via ATS Portal",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
