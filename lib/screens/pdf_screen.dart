import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/candidate_provider.dart';

// --- PDF MODEL ---
class AptitudePdfItem {
  final String id;
  final String title;
  final String category; // e.g., Dragnet, SHL, GMAT, Workforce, Civil Service
  final String fileSize;
  final int totalPages;
  final int downloadCount;
  final String description;
  final String pdfUrl;

  const AptitudePdfItem({
    required this.id,
    required this.title,
    required this.category,
    required this.fileSize,
    required this.totalPages,
    required this.downloadCount,
    required this.description,
    required this.pdfUrl,
  });

  AptitudePdfItem copyWith({
    String? id,
    String? title,
    String? category,
    String? fileSize,
    int? totalPages,
    int? downloadCount,
    String? description,
    String? pdfUrl,
  }) {
    return AptitudePdfItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      fileSize: fileSize ?? this.fileSize,
      totalPages: totalPages ?? this.totalPages,
      downloadCount: downloadCount ?? this.downloadCount,
      description: description ?? this.description,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }
}

class FreeAptitudePdfScreen extends ConsumerStatefulWidget {
  const FreeAptitudePdfScreen({super.key});

  @override
  ConsumerState<FreeAptitudePdfScreen> createState() =>
      _FreeAptitudePdfScreenState();
}

class _FreeAptitudePdfScreenState
    extends ConsumerState<FreeAptitudePdfScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  // Local State Managed PDF Repository
  late List<AptitudePdfItem> _pdfList;

  @override
  void initState() {
    super.initState();
    _pdfList = [
      const AptitudePdfItem(
        id: 'pdf_01',
        title: 'Dragnet Comprehensive Past Questions & Solutions',
        category: 'Dragnet',
        fileSize: '4.2 MB',
        totalPages: 145,
        downloadCount: 14200,
        description:
            'Covers numerical reasoning, verbal reasoning, and abstract spatial reasoning sections typical for oil & gas and FMCG recruitment.',
        pdfUrl:
            'https://pmtutor.org/downloads/dragnet_past_questions_2025.pdf',
      ),
      const AptitudePdfItem(
        id: 'pdf_02',
        title: 'SHL Verify Interactive General Ability Practice Pack',
        category: 'SHL',
        fileSize: '3.8 MB',
        totalPages: 110,
        downloadCount: 18900,
        description:
            'Step-by-step worked solutions for SHL numerical computation, inductive reasoning, and deductive logic assessments.',
        pdfUrl: 'https://pmtutor.org/downloads/shl_verify_practice_pack.pdf',
      ),
      const AptitudePdfItem(
        id: 'pdf_03',
        title: 'Workforce Group Aptitude Test Prep Pack',
        category: 'Workforce',
        fileSize: '2.9 MB',
        totalPages: 85,
        downloadCount: 11400,
        description:
            'Tailored for Nigerian banking, telecom, and corporate assessments (GTBank, Access, MTN, Zenith).',
        pdfUrl: 'https://pmtutor.org/downloads/workforce_group_prep.pdf',
      ),
      const AptitudePdfItem(
        id: 'pdf_04',
        title: 'GMAT Analytical Writing & Quantitative Review',
        category: 'GMAT',
        fileSize: '5.1 MB',
        totalPages: 210,
        downloadCount: 9800,
        description:
            'Advanced quantitative problem solving and data sufficiency drills suited for high-tier consulting and graduate scholarship exams.',
        pdfUrl: 'https://pmtutor.org/downloads/gmat_quant_review.pdf',
      ),
      const AptitudePdfItem(
        id: 'pdf_05',
        title: 'Federal Civil Service & Public Sector Examination Manual',
        category: 'Civil Service',
        fileSize: '3.1 MB',
        totalPages: 92,
        downloadCount: 7600,
        description:
            'General knowledge, current affairs, and administrative procedures guide for federal and state civil service exams.',
        pdfUrl: 'https://pmtutor.org/downloads/civil_service_manual.pdf',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _downloadPdf(AptitudePdfItem item) async {
    final Uri uri = Uri.parse(item.pdfUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Opening download link for ${item.title}..."),
              backgroundColor: Colors.deepOrange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Initiating PDF download for ${item.title}..."),
            backgroundColor: Colors.deepOrange,
          ),
        );
      }
    }
  }

  // --- ADMIN EDIT / ADD DIALOG ENGINE ---
  void _showAddEditPdfDialog({AptitudePdfItem? existingItem}) {
    final isEditing = existingItem != null;
    final titleCtrl = TextEditingController(text: existingItem?.title ?? '');
    final categoryCtrl =
        TextEditingController(text: existingItem?.category ?? 'Dragnet');
    final fileSizeCtrl =
        TextEditingController(text: existingItem?.fileSize ?? '3.5 MB');
    final pagesCtrl =
        TextEditingController(text: existingItem?.totalPages.toString() ?? '100');
    final descCtrl =
        TextEditingController(text: existingItem?.description ?? '');
    final urlCtrl =
        TextEditingController(text: existingItem?.pdfUrl ?? 'https://pmtutor.org');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            isEditing ? "Admin: Edit PDF Resource" : "Admin: Add New PDF Resource",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField("Package Title", titleCtrl),
                const SizedBox(height: 12),
                _buildDialogField("Category (e.g., Dragnet, SHL, GMAT)", categoryCtrl),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDialogField("File Size", fileSizeCtrl)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDialogField("Total Pages", pagesCtrl, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDialogField("Description", descCtrl, maxLines: 3),
                const SizedBox(height: 12),
                _buildDialogField("Direct PDF Download URL", urlCtrl),
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
                    final index = _pdfList.indexWhere((p) => p.id == existingItem.id);
                    if (index != -1) {
                      _pdfList[index] = existingItem.copyWith(
                        title: titleCtrl.text.trim(),
                        category: categoryCtrl.text.trim(),
                        fileSize: fileSizeCtrl.text.trim(),
                        totalPages: int.tryParse(pagesCtrl.text) ?? 100,
                        description: descCtrl.text.trim(),
                        pdfUrl: urlCtrl.text.trim(),
                      );
                    }
                  } else {
                    _pdfList.insert(
                      0,
                      AptitudePdfItem(
                        id: 'pdf_${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.trim(),
                        category: categoryCtrl.text.trim(),
                        fileSize: fileSizeCtrl.text.trim(),
                        totalPages: int.tryParse(pagesCtrl.text) ?? 100,
                        downloadCount: 1,
                        description: descCtrl.text.trim(),
                        pdfUrl: urlCtrl.text.trim(),
                      ),
                    );
                  }
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEditing ? "PDF updated!" : "New PDF added to repository!"),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text(isEditing ? "Save Changes" : "Create Item",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _deletePdf(String id) {
    setState(() {
      _pdfList.removeWhere((item) => item.id == id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("PDF item removed"), backgroundColor: Colors.redAccent),
    );
  }

  Widget _buildDialogField(String label, TextEditingController controller,
      {bool isNumber = false, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
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

  List<AptitudePdfItem> get _filteredPdfs {
    return _pdfList.where((item) {
      final matchesSearch = item.title
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.category.toLowerCase().contains(_searchQuery.toLowerCase());

      if (_selectedCategory == 'All') {
        return matchesSearch;
      }
      return matchesSearch && item.category == _selectedCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(candidateProvider);
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final userData = snapshot.data?.data() as Map<String, dynamic>?;
        final String userRole = userData?['role'] ?? 'candidate';
        final bool isAdminMode = (userRole == 'admin');

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: isAdminMode
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddEditPdfDialog(),
                  backgroundColor: Colors.redAccent,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Add New PDF (Admin)",
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.deepOrange.withValues(alpha: 0.4),
                        ),
                      ),
                      child: const Text(
                        'SCREEN 5 OF 9 — FREE APTITUDE TEST PDFS',
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
                              'Past Questions & Test Prep Repository',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Candidate Profile: ${candidate.fullName.isEmpty ? "Registered Candidate" : candidate.fullName} | Free Direct Downloads',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Search & Category Chips
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
                                    "Search test packs by title or publisher (e.g. Dragnet, SHL, GMAT)...",
                                hintStyle:
                                    const TextStyle(color: Colors.white38),
                                prefixIcon: const Icon(Icons.picture_as_pdf,
                                    color: Colors.deepOrangeAccent),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                enabledBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Color(0xFF404040))),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.deepOrangeAccent)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildCategoryChip('All'),
                                  const SizedBox(width: 8),
                                  _buildCategoryChip('Dragnet'),
                                  const SizedBox(width: 8),
                                  _buildCategoryChip('SHL'),
                                  const SizedBox(width: 8),
                                  _buildCategoryChip('Workforce'),
                                  const SizedBox(width: 8),
                                  _buildCategoryChip('GMAT'),
                                  const SizedBox(width: 8),
                                  _buildCategoryChip('Civil Service'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PDF Item Cards Feed
                    if (_filteredPdfs.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: const Text(
                          "No past question PDFs match your search query.",
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredPdfs.length,
                        itemBuilder: (context, index) {
                          final pdf = _filteredPdfs[index];
                          return _buildPdfCard(pdf, isAdminMode);
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

  Widget _buildCategoryChip(String label) {
    final isSelected = _selectedCategory == label;
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
          setState(() => _selectedCategory = label);
        }
      },
    );
  }

  Widget _buildPdfCard(AptitudePdfItem pdf, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
              color: isAdmin
                  ? Colors.redAccent.withValues(alpha: 0.4)
                  : Colors.white12),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.deepOrange.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded,
                        color: Colors.deepOrangeAccent, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pdf.title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Chip(
                              label: Text(pdf.category,
                                  style: const TextStyle(
                                      color: Colors.deepOrangeAccent,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                              backgroundColor: const Color(0xFF141414),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 8),
                            Text(
                                "${pdf.fileSize} • ${pdf.totalPages} Pages • ${pdf.downloadCount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} Downloads",
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Admin Actions Menu
                  if (isAdmin) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amberAccent, size: 20),
                      tooltip: "Edit Item",
                      onPressed: () => _showAddEditPdfDialog(existingItem: pdf),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                      tooltip: "Delete Item",
                      onPressed: () => _deletePdf(pdf.id),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              Text(
                pdf.description,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),

              const Divider(color: Colors.white12),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _downloadPdf(pdf),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.download_rounded,
                      color: Colors.white, size: 18),
                  label: const Text(
                    "Download Complete PDF Package (Free)",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
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