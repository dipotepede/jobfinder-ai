import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/candidate_provider.dart';

class ContactProcurementScreen extends ConsumerStatefulWidget {
  const ContactProcurementScreen({super.key});

  @override
  ConsumerState<ContactProcurementScreen> createState() =>
      _ContactProcurementScreenState();
}

class _ContactProcurementScreenState
    extends ConsumerState<ContactProcurementScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountPaidCtrl = TextEditingController();
  final TextEditingController _paymentRefCtrl = TextEditingController();
  final TextEditingController _notesCtrl = TextEditingController();

  String _selectedPaymentFor = 'PMtutor Training Course / eBook';
  bool _isSubmitting = false;

  // Corporate Banking Parameters
  final Map<String, String> _bankDetails = const {
    'bankName': 'Access Bank Plc',
    'accountName': 'PMtutor / JOBFinder AI Services',
    'accountNumber': '0041234567',
    'sortCode': '044-150149',
    'supportEmail': 'support@pmtutor.org',
    'supportPhone': '+234 803 301 2345',
  };

  @override
  void dispose() {
    _amountPaidCtrl.dispose();
    _paymentRefCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$label copied to clipboard!"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _submitPaymentProof() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final user = FirebaseAuth.instance.currentUser;
    final candidate = ref.read(candidateProvider);

    try {
      await FirebaseFirestore.instance.collection('payment_verifications').add({
        'uid': user?.uid ?? 'anonymous',
        'candidateName': candidate.fullName.isNotEmpty
            ? candidate.fullName
            : (user?.email ?? 'Registered User'),
        'email': user?.email ?? 'N/A',
        'paymentFor': _selectedPaymentFor,
        'amountPaid': _amountPaidCtrl.text.trim(),
        'paymentReference': _paymentRefCtrl.text.trim(),
        'additionalNotes': _notesCtrl.text.trim(),
        'status': 'pending_approval',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => _isSubmitting = false);
        _amountPaidCtrl.clear();
        _paymentRefCtrl.clear();
        _notesCtrl.clear();

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.greenAccent),
                SizedBox(width: 8),
                Text("Payment Proof Submitted",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            content: const Text(
              "Your payment reference has been uploaded to the Admin Control Panel. Access will be unlocked automatically once verified.",
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Submission failed: $e"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final candidate = ref.watch(candidateProvider);

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
                  'SCREEN 8 OF 9 — CHECKOUT, PROCUREMENT & BANKING CONTACT',
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
                        'Direct Bank Transfer & Corporate Procurement',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Candidate: ${candidate.fullName.isEmpty ? "Registered User" : candidate.fullName} | Instant Verification Pipeline',
                        style: const TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Bank Details Card
              Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.deepOrangeAccent, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.account_balance, color: Colors.deepOrangeAccent, size: 24),
                          SizedBox(width: 10),
                          Text(
                            "Corporate Direct Banking Details",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141414),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          children: [
                            _buildBankRow("Bank Name", _bankDetails['bankName']!),
                            const Divider(color: Colors.white12),
                            _buildBankRow("Account Name", _bankDetails['accountName']!),
                            const Divider(color: Colors.white12),
                            _buildBankRow("Account Number", _bankDetails['accountNumber']!, canCopy: true),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          const Icon(Icons.email, color: Colors.white60, size: 16),
                          const SizedBox(width: 6),
                          Text("Support: ${_bankDetails['supportEmail']}", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(width: 16),
                          const Icon(Icons.phone, color: Colors.white60, size: 16),
                          const SizedBox(width: 6),
                          Text(_bankDetails['supportPhone']!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Verification Form Card
              Card(
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Colors.white12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Upload Payment Verification Proof",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Submit your transfer details below for instant admin verification and download access clearance.",
                          style: TextStyle(color: Colors.white60, fontSize: 13),
                        ),
                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          value: _selectedPaymentFor,
                          dropdownColor: const Color(0xFF2A2A2A),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: "Purpose of Payment",
                            labelStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'PMtutor Training Course / eBook', child: Text('PMtutor Training Course / eBook')),
                            DropdownMenuItem(value: 'PMP BootCamp Enrolment', child: Text('PMP BootCamp Enrolment')),
                            DropdownMenuItem(value: 'CBAP Business Analysis Prep', child: Text('CBAP Business Analysis Prep')),
                            DropdownMenuItem(value: 'Lean Six Sigma Black Belt', child: Text('Lean Six Sigma Black Belt')),
                            DropdownMenuItem(value: 'Corporate Invoicing / Bulk Access', child: Text('Corporate Invoicing / Bulk Access')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPaymentFor = val);
                          },
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _amountPaidCtrl,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(
                                  labelText: "Amount Paid (NGN)",
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
                                ),
                                validator: (val) => val == null || val.isEmpty ? "Enter amount paid" : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _paymentRefCtrl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(
                                  labelText: "Bank Reference / Session ID",
                                  labelStyle: TextStyle(color: Colors.white70),
                                  border: OutlineInputBorder(),
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
                                ),
                                validator: (val) => val == null || val.isEmpty ? "Enter reference ID" : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _notesCtrl,
                          maxLines: 2,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: "Additional Notes / Depositor Name",
                            labelStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepOrange)),
                          ),
                        ),
                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _submitPaymentProof,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            icon: _isSubmitting
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                            label: Text(
                              _isSubmitting ? "Submitting Proof..." : "Submit Payment Proof to Admin Panel",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBankRow(String label, String value, {bool canCopy = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
        Row(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            if (canCopy) ...[
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.copy, color: Colors.deepOrangeAccent, size: 16),
                tooltip: "Copy Account Number",
                onPressed: () => _copyToClipboard(value, "Account Number"),
              ),
            ],
          ],
        ),
      ],
    );
  }
}