import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/candidate_provider.dart';
import '../main.dart';

// --- EBOOK MODEL ---
class EBookItem {
  final String id;
  final String title;
  final String author;
  final String category;
  final String priceNgn;
  final String format;
  final int pageCount;
  final String description;
  final String coverAssetUrl;
  final String downloadUrl;

  const EBookItem({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.priceNgn,
    required this.format,
    required this.pageCount,
    required this.description,
    required this.coverAssetUrl,
    required this.downloadUrl,
  });

  EBookItem copyWith({
    String? id,
    String? title,
    String? author,
    String? category,
    String? priceNgn,
    String? format,
    int? pageCount,
    String? description,
    String? coverAssetUrl,
    String? downloadUrl,
  }) {
    return EBookItem(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      category: category ?? this.category,
      priceNgn: priceNgn ?? this.priceNgn,
      format: format ?? this.format,
      pageCount: pageCount ?? this.pageCount,
      description: description ?? this.description,
      coverAssetUrl: coverAssetUrl ?? this.coverAssetUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
    );
  }
}

class BooksHubScreen extends ConsumerStatefulWidget {
  const BooksHubScreen({super.key});

  @override
  ConsumerState<BooksHubScreen> createState() => _BooksHubScreenState();
}

class _BooksHubScreenState extends ConsumerState<BooksHubScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  late List<EBookItem> _booksList;

  @override
  void initState() {
    super.initState();
    _booksList = [
      const EBookItem(
        id: 'book_01',
        title: 'PMP Exam Mastery: 1,000+ Real Scenario Exam Questions',
        author: 'Dipo Tepede, MSc, PMP, ICBB',
        category: 'Project Management',
        priceNgn: '₦15,000',
        format: 'PDF + Solution Manual',
        pageCount: 380,
        description:
            'Exhaustive scenario-based preparation manual fully aligned with current PMI ECO frameworks, agile sprint hybrid models, and EVM calculations.',
        coverAssetUrl: 'https://pmtutor.org/assets/pmp_mastery.png',
        downloadUrl: 'https://pmtutor.org/downloads/pmp_exam_mastery.pdf',
      ),
      const EBookItem(
        id: 'book_02',
        title: 'CBAP Business Analysis Blueprint: BABOK v3 Applied',
        author: 'Dipo Tepede, Lead Consultant',
        category: 'Business Analysis',
        priceNgn: '₦18,000',
        format: 'PDF + BPMN Templates',
        pageCount: 320,
        description:
            'Practical guide to enterprise requirement engineering, root cause analysis (RCA), and IIBA CBAP certification techniques.',
        coverAssetUrl: 'https://pmtutor.org/assets/cbap_blueprint.png',
        downloadUrl: 'https://pmtutor.org/downloads/cbap_blueprint.pdf',
      ),
      const EBookItem(
        id: 'book_03',
        title: 'Lean Six Sigma Black Belt (DMAIC) Operational Toolkit',
        author: 'Continuous Improvement Press',
        category: 'Six Sigma',
        priceNgn: '₦22,000',
        format: 'PDF + Minitab Data Files',
        pageCount: 410,
        description:
            'Step-by-step DMAIC roadmap covering Design of Experiments (DOE), SPC control charts, and yield optimization models.',
        coverAssetUrl: 'https://pmtutor.org/assets/lssbb_toolkit.png',
        downloadUrl: 'https://pmtutor.org/downloads/lssbb_toolkit.pdf',
      ),
      const EBookItem(
        id: 'book_04',
        title: 'Python for Technical Business Analysts & Systems Engineers',
        author: 'JOBFinder AI Engineering Series',
        category: 'Data & AI',
        priceNgn: '₦12,500',
        format: 'PDF + Jupyter Notebooks',
        pageCount: 260,
        description:
            'Hands-on guide to automating data cleaning, API telemetry exports, and PyTorch machine learning baseline integration.',
        coverAssetUrl: 'https://pmtutor.org/assets/python_ba.png',
        downloadUrl: 'https://pmtutor.org/downloads/python_for_ba.pdf',
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _proceedToCheckout(EBookItem book) {
    ref.read(selectedIndexProvider.notifier).state = 7; // Route to Screen 8

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Selected '${book.title}'. Complete payment via Screen 8 to unlock this specific title."),
        backgroundColor: Colors.deepOrange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _downloadBookPdf(EBookItem book) async {
    final Uri uri = Uri.parse(book.downloadUrl);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Downloading '${book.title}'..."), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Initiating download for ${book.title}..."), backgroundColor: Colors.green),
        );
      }
    }
  }

  void _showAddEditBookDialog({EBookItem? existingBook}) {
    final isEditing = existingBook != null;
    final titleCtrl = TextEditingController(text: existingBook?.title ?? '');
    final authorCtrl = TextEditingController(text: existingBook?.author ?? 'Dipo Tepede');
    final categoryCtrl = TextEditingController(text: existingBook?.category ?? 'Project Management');
    final priceCtrl = TextEditingController(text: existingBook?.priceNgn ?? '₦15,000');
    final formatCtrl = TextEditingController(text: existingBook?.format ?? 'PDF + Solution Manual');
    final pagesCtrl = TextEditingController(text: existingBook?.pageCount.toString() ?? '300');
    final descCtrl = TextEditingController(text: existingBook?.description ?? '');
    final urlCtrl = TextEditingController(text: existingBook?.downloadUrl ?? 'https://pmtutor.org/downloads/sample.pdf');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            isEditing ? "Admin: Edit eBook Details" : "Admin: Add New eBook",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDialogField("eBook Title", titleCtrl),
                const SizedBox(height: 12),
                _buildDialogField("Author Name", authorCtrl),
                const SizedBox(height: 12),
                _buildDialogField("Category", categoryCtrl),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDialogField("Price (NGN)", priceCtrl)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildDialogField("Page Count", pagesCtrl, isNumber: true)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildDialogField("Format", formatCtrl),
                const SizedBox(height: 12),
                _buildDialogField("Description", descCtrl, maxLines: 3),
                const SizedBox(height: 12),
                _buildDialogField("Download Link (PDF URL)", urlCtrl),
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
                    final index = _booksList.indexWhere((b) => b.id == existingBook.id);
                    if (index != -1) {
                      _booksList[index] = existingBook.copyWith(
                        title: titleCtrl.text.trim(),
                        author: authorCtrl.text.trim(),
                        category: categoryCtrl.text.trim(),
                        priceNgn: priceCtrl.text.trim(),
                        format: formatCtrl.text.trim(),
                        pageCount: int.tryParse(pagesCtrl.text) ?? 300,
                        description: descCtrl.text.trim(),
                        downloadUrl: urlCtrl.text.trim(),
                      );
                    }
                  } else {
                    _booksList.insert(
                      0,
                      EBookItem(
                        id: 'book_${DateTime.now().millisecondsSinceEpoch}',
                        title: titleCtrl.text.trim(),
                        author: authorCtrl.text.trim(),
                        category: categoryCtrl.text.trim(),
                        priceNgn: priceCtrl.text.trim(),
                        format: formatCtrl.text.trim(),
                        pageCount: int.tryParse(pagesCtrl.text) ?? 300,
                        description: descCtrl.text.trim(),
                        coverAssetUrl: 'https://pmtutor.org/assets/default_cover.png',
                        downloadUrl: urlCtrl.text.trim(),
                      ),
                    );
                  }
                });
                Navigator.pop(context);
              },
              child: Text(isEditing ? "Save Changes" : "Publish eBook", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _deleteBook(String id) {
    setState(() => _booksList.removeWhere((b) => b.id == id));
  }

  Widget _buildDialogField(String label, TextEditingController controller, {bool isNumber = false, int maxLines = 1}) {
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

  List<EBookItem> get _filteredBooks {
    return _booksList.where((book) {
      final matchesSearch = book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          book.category.toLowerCase().contains(_searchQuery.toLowerCase());

      if (_selectedCategory == 'All') return matchesSearch;
      return matchesSearch && book.category == _selectedCategory;
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

        // Extract list of explicitly purchased book IDs
        final List<dynamic> purchasedBookIdsRaw = userData?['purchasedBookIds'] ?? [];
        final List<String> purchasedBookIds = purchasedBookIdsRaw.map((e) => e.toString()).toList();

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: isAdminMode
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddEditBookDialog(),
                  backgroundColor: Colors.redAccent,
                  icon: const Icon(Icons.menu_book, color: Colors.white),
                  label: const Text("Add New eBook (Admin)", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.4)),
                      ),
                      child: const Text(
                        'SCREEN 6 OF 9 — JOBFINDER EBOOK & STORE HUB',
                        style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
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
                              'Technical Career eBooks & Prep Manuals',
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Candidate: ${candidate.fullName.isEmpty ? "Registered User" : candidate.fullName} | Unlocked Titles: ${purchasedBookIds.length}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    InkWell(
                      onTap: () => ref.read(selectedIndexProvider.notifier).state = 7,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.deepOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.payment, color: Colors.deepOrangeAccent, size: 20),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Need corporate invoicing or direct bank transfer details? Jump to Screen 8: Procurement & Banking Contact →",
                                style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Card(
                      color: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _searchController,
                              style: const TextStyle(color: Colors.white),
                              onChanged: (val) => setState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText: "Search books by title, author, or discipline...",
                                hintStyle: const TextStyle(color: Colors.white38),
                                prefixIcon: const Icon(Icons.search, color: Colors.deepOrangeAccent),
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
                                  _buildCategoryChip('All'),
                                  const SizedBox(width: 8),
                                  _buildCategoryChip('Project Management'),
                                  const SizedBox(width: 8),
                                  _buildCategoryChip('Business Analysis'),
                                  const SizedBox(width: 8),
                                  _buildCategoryChip('Six Sigma'),
                                  const SizedBox(width: 8),
                                  _buildCategoryChip('Data & AI'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_filteredBooks.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: const Text("No eBooks match your search query.", style: TextStyle(color: Colors.white54, fontSize: 14)),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredBooks.length,
                        itemBuilder: (context, index) {
                          final book = _filteredBooks[index];
                          // Book is downloadable IF user is Admin OR book.id is inside purchasedBookIds
                          final bool isUnlockedForUser = isAdminMode || purchasedBookIds.contains(book.id);
                          return _buildBookCard(book, isAdminMode, isUnlockedForUser);
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
      label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      selected: isSelected,
      selectedColor: Colors.deepOrange,
      backgroundColor: const Color(0xFF141414),
      onSelected: (bool selected) {
        if (selected) setState(() => _selectedCategory = label);
      },
    );
  }

  Widget _buildBookCard(EBookItem book, bool isAdmin, bool isUnlocked) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isAdmin ? Colors.redAccent.withValues(alpha: 0.4) : Colors.white12),
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
                      border: Border.all(color: Colors.deepOrange.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.auto_stories, color: Colors.deepOrangeAccent, size: 32),
                  ),
                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text("Author: ${book.author}", style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Chip(
                              label: Text(book.category, style: const TextStyle(color: Colors.deepOrangeAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                              backgroundColor: const Color(0xFF141414),
                              padding: EdgeInsets.zero,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            const SizedBox(width: 8),
                            Text("${book.format} • ${book.pageCount} Pages", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  if (isAdmin) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.amberAccent, size: 20),
                      onPressed: () => _showAddEditBookDialog(existingBook: book),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.redAccent, size: 20),
                      onPressed: () => _deleteBook(book.id),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              Text(book.description, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(book.priceNgn, style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  if (isUnlocked)
                    ElevatedButton.icon(
                      onPressed: () => _downloadBookPdf(book),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      icon: const Icon(Icons.download_rounded, color: Colors.white, size: 16),
                      label: const Text("Download eBook PDF Now", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: () => _proceedToCheckout(book),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white, size: 16),
                      label: const Text("Purchase & Request Access", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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