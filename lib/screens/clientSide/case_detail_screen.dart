import 'package:NyayaMitra/models/case_model';
import 'package:NyayaMitra/models/user_model';
import 'package:NyayaMitra/screens/clientSide/all_cases_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/db_service.dart';
import '../../widgets/common.dart';

class CaseDetailScreen extends StatefulWidget {
  final CaseModel caseModel;
  const CaseDetailScreen({Key? key, required this.caseModel}) : super(key: key);

  @override
  State<CaseDetailScreen> createState() => _CaseDetailScreenState();
}

class _CaseDetailScreenState extends State<CaseDetailScreen> {
  final DbService _dbService = DbService();
  late Future<Map<String, UserModel?>> _userDetailsFuture;

  @override
  void initState() {
    super.initState();
    _userDetailsFuture = _fetchUserDetails();
  }

  Future<Map<String, UserModel?>> _fetchUserDetails() async {
    final client = await _dbService.getUserProfile(widget.caseModel.clientId);
    final lawyer = widget.caseModel.lawyerId != null
        ? await _dbService.getUserProfile(widget.caseModel.lawyerId!)
        : null;
    return {'client': client, 'lawyer': lawyer};
  }

  @override
  Widget build(BuildContext context) {
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
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Text(
                        widget.caseModel.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // --- DETAILS SCROLL VIEW ---
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0),
                  child: Column(
                    children: [
                      _buildInfoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Case Summary"),
                            _buildDetailRow(
                                "Case Type", widget.caseModel.caseType),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                                "Court Name", widget.caseModel.courtName),
                            const SizedBox(height: 8),
                            const Text("Description",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            const SizedBox(height: 4),
                            Text(widget.caseModel.description,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 16)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        child: _buildSectionsUI(),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle("Status & Timeline"),
                            Row(
                              children: [
                                _buildDetailRow("Priority",
                                    widget.caseModel.priority.capitalize()),
                                const Spacer(),
                                StatusPill(status: widget.caseModel.status),
                              ],
                            ),
                            const Divider(color: Colors.white24, height: 24),
                            Row(
                              children: [
                                _buildDateInfo("Hearing Date",
                                    widget.caseModel.hearingDate),
                                const Spacer(),
                                _buildDateInfo(
                                    "Due Date", widget.caseModel.dueDate,
                                    alignRight: true),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildDateInfo(
                                "Last Updated", widget.caseModel.lastUpdated),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildInfoCard(
                        child: FutureBuilder<Map<String, UserModel?>>(
                          future: _userDetailsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }
                            final client = snapshot.data?['client'];
                            final lawyer = snapshot.data?['lawyer'];

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle("People Involved"),
                                if (client != null)
                                  _buildUserTile(user: client, role: "Client"),
                                const Divider(
                                    color: Colors.white24, height: 24),
                                if (lawyer != null)
                                  _buildUserTile(user: lawyer, role: "Lawyer")
                                else
                                  const Text("No lawyer assigned yet.",
                                      style: TextStyle(color: Colors.white70)),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
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

  Widget _buildInfoCard({required Widget child}) {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildDateInfo(String title, DateTime date,
      {bool alignRight = false}) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(DateFormat.yMMMd().format(date),
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSectionsUI() {
    final sections = widget.caseModel.applicableSections
            ?.split(',')
            .map((e) => e.trim())
            .toList() ??
        [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Applicable Sections"),
        if (sections.isNotEmpty)
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: sections
                .map((section) => Chip(
                      label: Text(section),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      labelStyle: const TextStyle(color: Colors.white),
                    ))
                .toList(),
          )
        else
          const Text("No sections listed for this case.",
              style: TextStyle(color: Colors.white70)),
      ],
    );
  }

  Widget _buildUserTile({required UserModel user, required String role}) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: user.profileImage != null
              ? NetworkImage(user.profileImage!)
              : null,
          child: user.profileImage == null
              ? const Icon(Icons.person, size: 28, color: Colors.white70)
              : null,
          backgroundColor: Colors.white.withOpacity(0.2),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(role,
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 4),
            Text(user.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
      ],
    );
  }
}
