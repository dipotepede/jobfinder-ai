import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/candidate_profile.dart';
import '../providers/candidate_provider.dart';
import '../main.dart';

class CandidateOnboardingScreen extends ConsumerStatefulWidget {
  const CandidateOnboardingScreen({super.key});

  @override
  ConsumerState<CandidateOnboardingScreen> createState() =>
      _CandidateOnboardingScreenState();
}

class _CandidateOnboardingScreenState
    extends ConsumerState<CandidateOnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _resumeController;
  
  // Default selection set to Entry Level / Recent Grad for broad accessibility
  String _selectedTargetRole = 'Recent Graduate / Entry Level';
  String _uploadedFileName = '';

  // Exhaustive Target Roles & Employment Status Options
  final List<String> _targetRoleOptions = [
    // --- Early Career & Status Transitions ---
    'Recent Graduate / Entry Level',
    'Student / Undergraduate',
    'Currently Unemployed / Job Seeker',
    'NYSC Corps Member',
    'Career Switcher / Transitioning Professional',

    // --- Remote & AI Specialty Tracks ---
    'Generative AI Evaluator / Trainer (Outlier, Remotasks)',
    'AI Prompt Engineer / Data Evaluator',
    'Global Remote Specialist',

    // --- Business, Data & Project Disciplines ---
    'Business Systems Analyst / Systems Analyst',
    'Project Analyst / Project Coordinator',
    'Data Analyst / Analytics Associate',
    'Project Manager / Program Manager',
    'Operations & Process Improvement Specialist',
    'Software Engineer / Application Developer',

    // --- Executive & Other ---
    'Executive / Senior Leadership',
    'Other / General Professional',
  ];

  @override
  void initState() {
    super.initState();
    final current = ref.read(candidateProvider);
    _nameController = TextEditingController(text: current.fullName);
    _emailController = TextEditingController();
    _phoneController = TextEditingController(text: '+234 ');
    _resumeController = TextEditingController(text: current.resumeText);
    
    if (_targetRoleOptions.contains(current.targetJobTitle)) {
      _selectedTargetRole = current.targetJobTitle;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _resumeController.dispose();
    super.dispose();
  }

  void _simulateFileUpload() {
    setState(() {
      _uploadedFileName = 'Candidate_CV_2026.pdf';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CV attached: Candidate_CV_2026.pdf'),
        backgroundColor: Colors.deepOrangeAccent,
      ),
    );
  }

  void _saveAndProceed() {
    if (_formKey.currentState!.validate()) {
      final updatedProfile = CandidateProfile(
        fullName: _nameController.text.trim(),
        targetJobTitle: _selectedTargetRole,
        targetIndustry: 'Remote & Global Markets',
        experienceLevel: 'Professional',
        resumeText: _resumeController.text.trim(),
      );

      ref.read(candidateProvider.notifier).saveProfile(updatedProfile);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully! Proceeding to AI Suite...'),
          backgroundColor: Colors.green,
        ),
      );

      // Transition to Screen 2: Unified AI Suite
      ref.read(selectedIndexProvider.notifier).state = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
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
                    'SCREEN 1 OF 9 — ASSESSMENT & PREP',
                    style: TextStyle(
                      color: Colors.deepOrangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title & Subtitle
                const Text(
                  'Candidate Intake & Profile Registration',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Input your target parameters and current background to seed the AI Diagnostic Engine.',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),

                // Dark Card Container
                Card(
                  color: const Color(0xFF1E1E1E),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Colors.deepOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Responsive Layout for Name & Email
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return Row(
                                children: [
                                  Expanded(child: _buildNameField()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildEmailField()),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _buildNameField(),
                                  const SizedBox(height: 16),
                                  _buildEmailField(),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        // Responsive Layout for Phone & Target Role
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (constraints.maxWidth > 600) {
                              return Row(
                                children: [
                                  Expanded(child: _buildPhoneField()),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildRoleDropdown()),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  _buildPhoneField(),
                                  const SizedBox(height: 16),
                                  _buildRoleDropdown(),
                                ],
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // Optional File Upload Trigger Area
                        const Text(
                          'Upload Raw CV / Resume (Optional):',
                          style: TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: _simulateFileUpload,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.deepOrange),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          icon: const Icon(
                            Icons.cloud_upload_outlined,
                            color: Colors.deepOrange,
                          ),
                          label: Text(
                            _uploadedFileName.isEmpty
                                ? 'Select PDF or DOCX File'
                                : 'Attached: $_uploadedFileName',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Resume Raw Text Field (Primary Ingestion)
                        TextFormField(
                          controller: _resumeController,
                          maxLines: 4,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Paste Experience Summary / Bullet Points',
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Color(0xFF404040)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.deepOrange),
                            ),
                            prefixIcon: Icon(Icons.description, color: Colors.deepOrange),
                          ),
                          validator: (val) => val == null || val.isEmpty
                              ? 'Please enter resume summary'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit / Proceed Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saveAndProceed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Unified AI Suite →',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Full Name',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepOrange),
        ),
        prefixIcon: Icon(Icons.person, color: Colors.deepOrange),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Please enter full name' : null,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Email Address',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepOrange),
        ),
        prefixIcon: Icon(Icons.email, color: Colors.deepOrange),
      ),
      validator: (val) =>
          val == null || !val.contains('@') ? 'Enter valid email' : null,
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(
        labelText: 'Mobile WhatsApp ID',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepOrange),
        ),
        prefixIcon: Icon(Icons.phone, color: Colors.deepOrange),
      ),
      validator: (val) =>
          val == null || val.isEmpty ? 'Enter contact number' : null,
    );
  }

  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedTargetRole,
      dropdownColor: const Color(0xFF1E1E1E),
      style: const TextStyle(color: Colors.white),
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Target Role / Current Status',
        labelStyle: TextStyle(color: Colors.white70),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF404040)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.deepOrange),
        ),
        prefixIcon: Icon(Icons.work, color: Colors.deepOrange),
      ),
      items: _targetRoleOptions.map((String role) {
        return DropdownMenuItem<String>(
          value: role,
          child: Text(
            role,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (val) {
        if (val != null) setState(() => _selectedTargetRole = val);
      },
    );
  }
}