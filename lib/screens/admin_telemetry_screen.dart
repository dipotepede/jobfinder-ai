import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/admin_provider.dart';

class AdminTelemetryScreen extends ConsumerStatefulWidget {
  const AdminTelemetryScreen({super.key});

  @override
  ConsumerState<AdminTelemetryScreen> createState() => _AdminTelemetryScreenState();
}

class _AdminTelemetryScreenState extends ConsumerState<AdminTelemetryScreen> {
  final List<Map<String, String>> _availableBooks = const [
    {'id': 'book_01', 'title': 'PMP Exam Mastery (₦15k)'},
    {'id': 'book_02', 'title': 'CBAP BA Blueprint (₦18k)'},
    {'id': 'book_03', 'title': 'LSS Black Belt Toolkit (₦22k)'},
    {'id': 'book_04', 'title': 'Python for Analysts (₦12.5k)'},
  ];

  Future<void> _toggleBookAccess(String uid, String bookId, bool currentlyHasAccess) async {
    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

      if (currentlyHasAccess) {
        await docRef.update({
          'purchasedBookIds': FieldValue.arrayRemove([bookId])
        });
      } else {
        await docRef.update({
          'purchasedBookIds': FieldValue.arrayUnion([bookId])
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentlyHasAccess ? "Access revoked for $bookId" : "Access granted for $bookId"),
            backgroundColor: currentlyHasAccess ? Colors.orangeAccent : Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating access: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _toggleAdminRole(String uid, String currentRole) async {
    final String newRole = currentRole == 'admin' ? 'candidate' : 'admin';
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({'role': newRole});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Role updated to ${newRole.toUpperCase()}"), backgroundColor: Colors.blueAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating role: $e"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  'SCREEN 9 OF 9 — SYSTEM ADMINISTRATOR CONTROL PANEL',
                  style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Itemized Approvals & Telemetry Panel',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Grant candidate access to specific paid eBook titles upon payment verification.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => AnalyticsService.exportTelemetryCsv(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    icon: const Icon(Icons.download, color: Colors.white, size: 16),
                    label: const Text("Export Telemetry CSV", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- VISUAL TELEMETRY SUMMARY DASHBOARD ---
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  int totalUsers = 0;
                  int totalBookUnlocks = 0;

                  if (snapshot.hasData) {
                    totalUsers = snapshot.data!.docs.length;
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final List<dynamic> books = data['purchasedBookIds'] ?? [];
                      totalBookUnlocks += books.length;
                    }
                  }

                  return Row(
                    children: [
                      Expanded(child: _buildTelemetryStatCard("Registered Candidates", "$totalUsers", Icons.people_outline, Colors.blueAccent)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildTelemetryStatCard("Total Unlocked Titles", "$totalBookUnlocks", Icons.menu_book, Colors.greenAccent)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('payment_verifications').where('status', isEqualTo: 'pending_approval').snapshots(),
                          builder: (context, paySnap) {
                            int pendingCount = paySnap.hasData ? paySnap.data!.docs.length : 0;
                            return _buildTelemetryStatCard("Pending Verifications", "$pendingCount", Icons.pending_actions, Colors.deepOrangeAccent);
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Registered Candidates & Itemized Book Access',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Card(
                      color: Color(0xFF1E1E1E),
                      child: Padding(padding: EdgeInsets.all(32.0), child: Center(child: CircularProgressIndicator(color: Colors.redAccent))),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Card(
                      color: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white12)),
                      child: const Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(child: Text("No registered user records found in Firestore.", style: TextStyle(color: Colors.white54, fontSize: 14))),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return Card(
                    color: const Color(0xFF1E1E1E),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.white12)),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: docs.length,
                      separatorBuilder: (context, index) => const Divider(color: Colors.white12, height: 1),
                      itemBuilder: (context, index) {
                        final userData = docs[index].data() as Map<String, dynamic>;
                        final String uid = docs[index].id;
                        final String fullName = userData['fullName'] ?? 'Unnamed Candidate';
                        final String email = userData['email'] ?? 'No email provided';
                        final String role = userData['role'] ?? 'candidate';

                        final List<dynamic> purchasedBookIdsRaw = userData['purchasedBookIds'] ?? [];
                        final List<String> purchasedBookIds = purchasedBookIdsRaw.map((e) => e.toString()).toList();

                        return ExpansionTile(
                          backgroundColor: const Color(0xFF181818),
                          collapsedBackgroundColor: Colors.transparent,
                          leading: CircleAvatar(
                            backgroundColor: purchasedBookIds.isNotEmpty ? Colors.green.withValues(alpha: 0.2) : Colors.deepOrange.withValues(alpha: 0.2),
                            child: Icon(purchasedBookIds.isNotEmpty ? Icons.menu_book : Icons.lock_clock, color: purchasedBookIds.isNotEmpty ? Colors.greenAccent : Colors.deepOrangeAccent),
                          ),
                          title: Row(
                            children: [
                              Text(fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(role.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                backgroundColor: role == 'admin' ? Colors.redAccent : const Color(0xFF141414),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                          subtitle: Text(
                            "$email\nUnlocked Titles: ${purchasedBookIds.length} of ${_availableBooks.length}",
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                          trailing: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert, color: Colors.white70),
                            color: const Color(0xFF2A2A2A),
                            onSelected: (value) {
                              if (value == 'toggle_role') _toggleAdminRole(uid, role);
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'toggle_role',
                                child: Text(role == 'admin' ? "Demote to Candidate" : "Promote to Admin", style: const TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Select eBook Titles Paid For:", style: TextStyle(color: Colors.deepOrangeAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _availableBooks.map((book) {
                                      final String bookId = book['id']!;
                                      final String bookTitle = book['title']!;
                                      final bool hasAccess = purchasedBookIds.contains(bookId);

                                      return FilterChip(
                                        selected: hasAccess,
                                        label: Text(bookTitle, style: TextStyle(color: hasAccess ? Colors.white : Colors.white70, fontSize: 11)),
                                        selectedColor: Colors.green,
                                        backgroundColor: const Color(0xFF242424),
                                        checkmarkColor: Colors.white,
                                        onSelected: (_) => _toggleBookAccess(uid, bookId, hasAccess),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryStatCard(String title, String value, IconData icon, Color themeColor) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: themeColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: themeColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: themeColor, size: 24),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(title, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}