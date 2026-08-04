import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/candidate_provider.dart';
import '../main.dart'; // Imports selectedIndexProvider for shell navigation

// --- COURSE PROGRAM MODEL ---
class CertificationCourse {
  final String id;
  final String title;
  final String acronym; // e.g. PMP, CBAP, LSSBB
  final String priceNgn;
  final String duration;
  final String schedule; // e.g. Next Cohort: Sept 12, 2026
  final String mode; // e.g. Virtual Live / Hybrid
  final String overview;
  final List<String> keyModules;
  final String pduCredits;

  const CertificationCourse({
    required this.id,
    required this.title,
    required this.acronym,
    required this.priceNgn,
    required this.duration,
    required this.schedule,
    required this.mode,
    required this.overview,
    required this.keyModules,
    required this.pduCredits,
  });

  CertificationCourse copyWith({
    String? id,
    String? title,
    String? acronym,
    String? priceNgn,
    String? duration,
    String? schedule,
    String? mode,
    String? overview,
    List<String>? keyModules,
    String? pduCredits,
  }) {
    return CertificationCourse(
      id: id ?? this.id,
      title: title ?? this.title,
      acronym: acronym ?? this.acronym,
      priceNgn: priceNgn ?? this.priceNgn,
      duration: duration ?? this.duration,
      schedule: schedule ?? this.schedule,
      mode: mode ?? this.mode,
      overview: overview ?? this.overview,
      keyModules: keyModules ?? this.keyModules,
      pduCredits: pduCredits ?? this.pduCredits,
    );
  }
}

class PmTutorGatewayScreen extends ConsumerStatefulWidget {
  const PmTutorGatewayScreen({super.key});

  @override
  ConsumerState<PmTutorGatewayScreen> createState() =>
      _PmTutorGatewayScreenState();
}

class _PmTutorGatewayScreenState extends ConsumerState<PmTutorGatewayScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  late List<CertificationCourse> _coursesList;

  @override
  void initState() {
    super.initState();
    _coursesList = [
      const CertificationCourse(
        id: 'course_01',
        title: 'Project Management Professional (PMP)® Exam Prep BootCamp',
        acronym: 'PMP',
        priceNgn: '₦120,000',
        duration: '4 Weeks (Saturdays & Sundays)',
        schedule: 'Upcoming Cohort: September 12, 2026',
        mode: 'Virtual Live Class (Zoom) + LMS Access',
        overview:
            'Comprehensive alignment with the current PMI® ECO framework covering Predictive, Agile, and Hybrid methodologies with 1,000+ simulation drills.',
        keyModules: [
          'People: Managing Teams & Conflict Resolution',
          'Process: EVM, Risk Management, & Sprint Backlogs',
          'Business Environment: Governance & Organizational Value',
        ],
        pduCredits: '35 Contact Hours / PDUs',
      ),
      const CertificationCourse(
        id: 'course_02',
        title: 'Certified Business Analysis Professional (CBAP)® Prep',
        acronym: 'CBAP',
        priceNgn: '₦150,000',
        duration: '5 Weeks (Weekend Intensive)',
        schedule: 'Upcoming Cohort: October 3, 2026',
        mode: 'Virtual Live Class + IIBA Simulation',
        overview:
            'Practical application of the BABOK® v3 Guide. Covers Enterprise Analysis, Requirements Lifecycle Management, and BPMN 2.0 Process Mapping.',
        keyModules: [
          'Strategy Analysis & Solution Evaluation',
          'Requirements Analysis & Design Definition (RADD)',
          'Elicitation & Collaboration Techniques',
        ],
        pduCredits: '35 IIBA Professional Development Hours',
      ),
      const CertificationCourse(
        id: 'course_03',
        title: 'Lean Six Sigma Black Belt (LSSBB) DMAIC Mastery',
        acronym: 'LSSBB',
        priceNgn: '₦220,000',
        duration: '6 Weeks (Hands-on Project Workshop)',
        schedule: 'Upcoming Cohort: October 17, 2026',
        mode: 'Hybrid (Live Virtual + Project Coaching)',
        overview:
            'Deep dive into the DMAIC framework, Design of Experiments (DOE), Statistical Process Control (SPC) with Minitab, and Kaizen quality governance.',
        keyModules: [
          'Define & Measure: Voice of Customer (VOC) & Process Capability',
          'Analyze & Improve: Factorial DOE, Hypothesis Testing, RCA',
          'Control: Control Charts (i-mR, Xbar-R) & Process Standardization',
        ],
        pduCredits: '60 Professional Development Credits',
      ),
      const CertificationCourse(
        id: 'course_04',
        title: 'Primavera P6 Professional Project Management Hands-on',
        acronym: 'P6',
        priceNgn: '₦95,000',
        duration: '2 Weeks (Practical Lab)',
        schedule: 'Upcoming Cohort: September 26, 2026',
        mode: 'Virtual Hands-on Lab',
        overview:
            'Practical scheduling software mastery for engineering, construction, oil & gas, and IT project planners. Learn WBS setup, baseline tracking, and S-curve generation.',
        keyModules: [
          'Work Breakdown Structure (WBS) & Enterprise Project Structure (EPS)',
          'Resource Allocation, Levelling, & Cost Loading',
          'Earned Value Analysis & S-Curve Reporting Export',
        ],
        pduCredits: '20 Practical Technical Credits',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _enrolInCourse(CertificationCourse course) {
    ref.read(selectedIndexProvider.notifier).state = 7; // Switch shell to Screen 8

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.school, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Enrolment initiated for '${course.acronym} - ${course.title}'. Proceed on Screen 8 to finalize registration.",
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.deepOrange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- ADMIN ADD / EDIT COURSE DIALOG ---
  void _showAddEditCourseDialog({CertificationCourse? existingCourse}) {
    final isEditing = existingCourse != null;
    final titleCtrl = TextEditingController(text: existingCourse?.title ?? '');
    final acronymCtrl = TextEditingController(text: existingCourse?.acronym ?? 'PMP');
    final priceCtrl = TextEditingController(text: existingCourse?.priceNgn ?? '₦120,000');
    final durationCtrl = TextEditingController(text: existingCourse?.duration ?? '4 Weeks');
    final scheduleCtrl = TextEditingController(text: existingCourse?.schedule ?? 'Upcoming Cohort: Sept 2026');
    final modeCtrl = TextEditingController(text: existingCourse?.mode ?? 'Virtual Live Class');
    final overviewCtrl = TextEditingController(text: existingCourse?.overview ?? '');
    final pdusCtrl = TextEditingController(text: existingCourse?.pduCredits ?? '35 Contact Hours');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            isEditing ? "Admin: Edit Certification Course" : "Admin: Add New Certification Program",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField("Course Title", titleCtrl),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDialogField("Acronym (e.g. PMP)", acronymCtrl)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDialogField("Fee (NGN)", priceCtrl)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDialogField("Duration", durationCtrl),
                const SizedBox(height: 12),
                _buildDialogField("Schedule / Next Cohort Date", scheduleCtrl),
                const SizedBox(height: 12),
                _buildDialogField("Delivery Mode", modeCtrl),
                const SizedBox(height: 12),
                _buildDialogField("PDU / Contact Hours", pdusCtrl),
                const SizedBox(height: 12),
                _buildDialogField("Course Overview", overviewCtrl, maxLines: 3),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: () {
                if (titleCtrl.text.isEmpty) return;

                setState(() {
                  if (isEditing) {
                    final index = _coursesList.indexWhere((c) => c.id == existingCourse.id);
                    if (index != -1) {
                      _coursesList[index] = existingCourse.copyWith(
                        title: titleCtrl.text.trim(),
                        acronym: acronymCtrl.text.trim(),
                        priceNgn: priceCtrl.text.trim(),
                        duration: durationCtrl.text.trim(),
                        schedule: scheduleCtrl.text.trim(),
                        mode: modeCtrl.text.trim(),
                        pduCredits: pdusCtrl.text.trim(),
                        overview: overviewCtrl.text.trim(),
                      );
                    }
                  } else {
                    _coursesList.insert(
                      0,
                      CertificationCourse(
                        id: 'course_${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.trim(),
                        acronym: acronymCtrl.text.trim(),
                        priceNgn: priceCtrl.text.trim(),
                        duration: durationCtrl.text.trim(),
                        schedule: scheduleCtrl.text.trim(),
                        mode: modeCtrl.text.trim(),
                        overview: overviewCtrl.text.trim(),
                        keyModules: ['Module 1: Foundations', 'Module 2: Core Execution', 'Module 3: Mastery Drill'],
                        pduCredits: pdusCtrl.text.trim(),
                      ),
                    );
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing ? "Course updated!" : "New program published to Gateway!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(isEditing ? "Save Changes" : "Publish Course",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _deleteCourse(String id) {
    setState(() => _coursesList.removeWhere((c) => c.id == id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Course removed from Gateway"), backgroundColor: Colors.redAccent),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
        border: const OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
      ),
    );
  }

  List<CertificationCourse> get _filteredCourses {
    return _coursesList.where((course) {
      final query = _searchQuery.toLowerCase();
      return course.title.toLowerCase().contains(query) ||
          course.acronym.toLowerCase().contains(query) ||
          course.overview.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(candidateProvider);
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final String userRole = userData?['role'] ?? 'candidate';
        final bool isAdminMode = (userRole == 'admin');

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: isAdminMode
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddEditCourseDialog(),
                  backgroundColor: Colors.redAccent,
                  icon: const Icon(Icons.add_task_rounded, color: Colors.white),
                  label: const Text("Add New Course (Admin)",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              : null,
          body: SingleChildScrollView(
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
                        border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'SCREEN 7 OF 9 — PMTUTOR PROFESSIONAL CERTIFICATION GATEWAY',
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
                              'Accredited Certification Bootcamps',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Candidate: ${candidate.fullName.isEmpty ? "Registered Candidate" : candidate.fullName} | PMtutor Official Partnership',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search Card
                    Card(
                      color: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.white12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: TextFormField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white),
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: "Search courses by acronym or title (e.g., PMP, CBAP, Six Sigma, Primavera)...",
                            hintStyle: const TextStyle(color: Colors.white38),
                            prefixIcon: const Icon(Icons.school_outlined, color: Colors.deepOrangeAccent),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF404040))),
                            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrangeAccent)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Course Feed
                    if (_filteredCourses.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: const Text(
                          "No training programs match your search query.",
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredCourses.length,
                        itemBuilder: (context, index) {
                          final course = _filteredCourses[index];
                          return _buildCourseCard(course, isAdminMode);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCourseCard(CertificationCourse course, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isAdmin ? Colors.redAccent.withValues(alpha: 0.4) : Colors.white12,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      course.acronym,
                      style: const TextStyle(
                        color: Colors.deepOrangeAccent,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${course.schedule} • ${course.duration}",
                          style: const TextStyle(color: Colors.amberAccent, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Delivery: ${course.mode} • Accreditation: ${course.pduCredits}",
                          style: const TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  if (isAdmin) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amberAccent, size: 20),
                      onPressed: () => _showAddEditCourseDialog(existingCourse: course),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                      onPressed: () => _deleteCourse(course.id),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),

              Text(
                course.overview,
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 14),

              // Syllabus Highlight Pills
              const Text(
                "Core Curriculum Highlights:",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: course.keyModules
                    .map((m) => Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: Colors.deepOrangeAccent, size: 14),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(m, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),

              const Divider(color: Colors.white12),
              const SizedBox(height: 8),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    course.priceNgn,
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _enrolInCourse(course),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.school, color: Colors.white, size: 16),
                    label: const Text(
                      "Enrol Now (Proceed to Screen 8)",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}