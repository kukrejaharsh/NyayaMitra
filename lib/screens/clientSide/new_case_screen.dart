import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/db_service.dart';
import '../../services/gemini_service.dart';

// A simple data class to hold the AI's structured response
class SuggestedSection {
  final String section;
  final String description;
  SuggestedSection({required this.section, required this.description});
}

class NewCaseScreen extends StatefulWidget {
  const NewCaseScreen({Key? key}) : super(key: key);

  @override
  State<NewCaseScreen> createState() => _NewCaseScreenState();
}

class _NewCaseScreenState extends State<NewCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _courtController = TextEditingController();

  DateTime? _dueDate;
  DateTime? _hearingDate;
  String _priority = "medium";
  String _caseType = "Criminal Law";

  bool _loading = false;
  bool _isAnalyzing = false;
  final DbService _dbService = DbService();

  Map<String, dynamic>? _selectedLawyer;
  bool get hasSelectedLawyer => _selectedLawyer != null;

  List<SuggestedSection> _suggestedSections = [];

  final List<String> _allCaseTypes = const [
    'Civil Law', 'Criminal Law', 'Corporate Law', 'Tax Law', 'Intellectual Property Law',
    'Family Law', 'Labour & Employment Law', 'Constitutional Law', 'Real Estate Law',
    'Cyber Law', 'Environmental Law', 'Banking & Finance Law', 'International Law', 'Other',
  ];

  Future<void> _analyzeDescription() async {
    if (_descController.text.trim().length < 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.orangeAccent,
          content: Text("Please enter a more detailed description to analyze."),
        ),
      );
      return;
    }

    setState(() => _isAnalyzing = true);

    final description = _descController.text.trim();
    final prompt = """
      You are an expert legal assistant for Indian law.
      Analyze the following case description and identify the most relevant sections of Indian law according to the Bharatiya Nyaya Sanhita (BNS).
      Your response MUST be a list where each item is on a new line.
      Each line MUST be in the format: "SECTION_CODE: Brief one-line description".
      For example:
      BNS 101: Murder
      BNS 109: Attempt to murder

      Do NOT add any introductory text, explanations, or bullet points. Only output the list.

      Case Description: "$description"
    """;

    try {
      final result = await GeminiService.askGemini(prompt);

      final lines = result.trim().split('\n');
      final newSections = <SuggestedSection>[];
      for (var line in lines) {
        final parts = line.split(':');
        if (parts.length == 2) {
          newSections.add(SuggestedSection(
            section: parts[0].trim(),
            description: parts[1].trim(),
          ));
        }
      }
      setState(() => _suggestedSections = newSections);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.redAccent,
              content: Text("AI analysis failed: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  // ✅ UPDATED: This function now shows a more modern modal bottom sheet
  Future<void> _showAddSectionDialog() async {
    final sectionController = TextEditingController();
    final descriptionController = TextEditingController();
    final dialogFormKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard handling
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          // This padding moves the content up when the keyboard appears
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: dialogFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Add Section Manually",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: sectionController,
                  decoration: const InputDecoration(
                    labelText: "Section Code (e.g., BNS 101)",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (v) => v!.isEmpty ? 'Section code is required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Brief Description",
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
                  ),
                  validator: (v) => v!.isEmpty ? 'Description is required' : null,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2575FC),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        if (dialogFormKey.currentState!.validate()) {
                          setState(() {
                            _suggestedSections.add(SuggestedSection(
                              section: sectionController.text.trim(),
                              description: descriptionController.text.trim(),
                            ));
                          });
                          Navigator.pop(context);
                        }
                      },
                      child: const Text("Add Section"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createCase() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final String? chosenLawyerId =
          hasSelectedLawyer ? _selectedLawyer!['userId'] as String? : null;

      final sectionsString =
          _suggestedSections.map((s) => s.section).join(', ');

      await _dbService.createCase(
        currentUserId: currentUserId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        courtName: _courtController.text.trim(),
        chosenLawyerId: chosenLawyerId,
        dueDate: _dueDate,
        hearingDate: _hearingDate,
        priority: _priority,
        caseType: _caseType,
        applicableSections: sectionsString.isNotEmpty ? sectionsString : null,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            backgroundColor: Colors.green,
            content: Text("✅ Case created successfully")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            backgroundColor: Colors.redAccent, content: Text("❌ Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selectDate(BuildContext context,
      {required bool isDueDate}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isDueDate) _dueDate = picked;
        else _hearingDate = picked;
      });
    }
  }

  Future<void> _chooseLawyer() async {
    final selected = await Navigator.pushNamed(context, '/choose-lawyer');
    if (selected is Map<String, dynamic> && mounted) {
      setState(() => _selectedLawyer = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_allCaseTypes.contains(_caseType)) {
      _caseType = _allCaseTypes.first;
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // --- HEADER ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text("File a New Case",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(width: 48), // Placeholder for alignment
                  ],
                ),
              ),
              // --- FORM SCROLL VIEW ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: _buildFormCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("Case Details"),
                          _buildTextFormField(
                              controller: _titleController,
                              label: "Case Title*",
                              validator: (v) =>
                                  v!.isEmpty ? "Title is required" : null),
                          const SizedBox(height: 16),
                          _buildTextFormField(
                              controller: _courtController,
                              label: "Court Name*",
                              validator: (v) => v!.isEmpty
                                  ? "Court name is required"
                                  : null),
                          const SizedBox(height: 16),
                          _buildCaseTypeSelector(),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _descController,
                            keyboardType: TextInputType.multiline,
                            minLines: 3,
                            maxLines: 5,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                                labelText: "Case Description*",
                                labelStyle: TextStyle(color: Colors.white70),
                                alignLabelWithHint: true,
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white38)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white))),
                            validator: (v) =>
                                v!.isEmpty ? "Description is required" : null,
                          ),
                          const Divider(color: Colors.white30, height: 30),
                          _buildSectionsUI(),
                          const Divider(color: Colors.white30, height: 30),
                          _buildSectionTitle("Dates & Priority"),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildDatePickerField(
                                      label: "Due Date*",
                                      date: _dueDate,
                                      onTap: () => _selectDate(context,
                                          isDueDate: true))),
                              const SizedBox(width: 16),
                              Expanded(
                                  child: _buildDatePickerField(
                                      label: "Hearing Date*",
                                      date: _hearingDate,
                                      onTap: () => _selectDate(context,
                                          isDueDate: false))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildPrioritySelector(),
                          const Divider(color: Colors.white30, height: 30),
                          _buildSectionTitle("Assign a Lawyer (Optional)"),
                           const SizedBox(height: 8),
                          _buildLawyerSelector(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // --- SUBMIT BUTTON ---
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2575FC)),
                    onPressed: _loading ? null : _createCase,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text("Create Case",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildFormCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildSectionsUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text("Applicable Sections", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                  onPressed: _showAddSectionDialog,
                  tooltip: "Add Section Manually",
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.9), foregroundColor: const Color(0xFF2575FC)),
                  onPressed: _isAnalyzing ? null : _analyzeDescription,
                  icon: _isAnalyzing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome, size: 16),
                  label: Text(_isAnalyzing ? "Analyzing..." : "Suggest"),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_suggestedSections.isNotEmpty)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _suggestedSections.length,
            itemBuilder: (context, index) {
              final item = _suggestedSections[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(item.section, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                subtitle: Text(item.description, style: const TextStyle(color: Colors.white70)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => setState(() => _suggestedSections.removeAt(index)),
                ),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(height: 8),
          )
        else
          const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text("No sections suggested yet.", style: TextStyle(color: Colors.white70)),
          )),
      ],
    );
  }
  
  Widget _buildTextFormField({required TextEditingController controller, required String label, String? Function(String?)? validator}) {
    return TextFormField(controller: controller, style: const TextStyle(color: Colors.white), decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white70), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))), validator: validator);
  }

  Widget _buildDatePickerField({required String label, DateTime? date, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: InputDecorator(decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white70), contentPadding: const EdgeInsets.symmetric(vertical: 8), enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))), child: Text(date != null ? DateFormat.yMMMd().format(date) : 'Not set', style: TextStyle(color: date != null ? Colors.white : Colors.white60, fontSize: 16))));
  }

  Widget _buildPrioritySelector() {
    return DropdownButtonFormField<String>(
      value: _priority,
      dropdownColor: const Color(0xFF2E3B85),
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(labelText: 'Priority', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
      items: ['low', 'medium', 'high'].map((label) => DropdownMenuItem(value: label, child: Text(label.capitalize()))).toList(),
      onChanged: (value) { if (value != null) setState(() => _priority = value); }
    );
  }

  Widget _buildCaseTypeSelector() {
    return DropdownButtonFormField<String>(
      value: _caseType,
      isExpanded: true,
      dropdownColor: const Color(0xFF2E3B85),
      style: const TextStyle(color: Colors.white),
      decoration: const InputDecoration(labelText: 'Case Type*', labelStyle: TextStyle(color: Colors.white70), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white38)), focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
      items: _allCaseTypes
          .map((label) => DropdownMenuItem(
                value: label,
                child: Text(label),
              ))
          .toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() => _caseType = value);
        }
      },
      validator: (value) =>
          value == null || value.isEmpty ? 'Please select a case type' : null,
    );
  }

  Widget _buildLawyerSelector() {
    return GestureDetector(
      onTap: _chooseLawyer,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.transparent, 
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundImage: hasSelectedLawyer && _selectedLawyer!['profileImage'] != null ? NetworkImage(_selectedLawyer!['profileImage']) : null,
              child: !hasSelectedLawyer || _selectedLawyer!['profileImage'] == null ? const Icon(Icons.person_search, size: 28, color: Colors.white70) : null,
              backgroundColor: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hasSelectedLawyer ? (_selectedLawyer!['name'] ?? 'Selected Lawyer') : 'Choose a Lawyer', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(hasSelectedLawyer ? "Tap to change or remove" : "Optional, you can assign one later", style: TextStyle(color: Colors.white70, fontSize: 13.5)),
                ],
              ),
            ),
            if (hasSelectedLawyer)
              IconButton(icon: const Icon(Icons.close, color: Colors.redAccent), onPressed: () => setState(() => _selectedLawyer = null))
            else
              const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}

