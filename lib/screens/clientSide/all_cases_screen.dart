import 'package:NyayaMitra/models/case_model';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../services/db_service.dart';
import '../../widgets/common.dart'; // Assuming EmptyState is here
import 'case_detail_screen.dart'; // ✅ 1. IMPORT the new screen

class AllCasesScreen extends StatefulWidget {
  const AllCasesScreen({Key? key}) : super(key: key);

  @override
  State<AllCasesScreen> createState() => _AllCasesScreenState();
}

class _AllCasesScreenState extends State<AllCasesScreen> {
  final DbService _dbService = DbService();
  late Future<List<CaseModel>> _casesFuture;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  String _filterStatus = "All";
  String _sortBy = "lastUpdated";
  bool _isSortDescending = true;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _casesFuture = _dbService.fetchClientCases(user.uid);
    } else {
      _casesFuture = Future.value([]);
    }

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showFilterSortSheet() async {
    // ... (This function remains unchanged)
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
                    const Text("All Cases",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              // --- SEARCH & FILTER BAR ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Search by case title...",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon:
                              const Icon(Icons.search, color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.filter_list_rounded,
                          color: Colors.white, size: 28),
                      onPressed: _showFilterSortSheet,
                      tooltip: "Filter & Sort",
                    ),
                  ],
                ),
              ),

              // --- CASE LIST ---
              Expanded(
                child: FutureBuilder<List<CaseModel>>(
                  future: _casesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError) {
                      return const EmptyState(message: "Error loading cases.");
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const EmptyState(message: "No cases found.");
                    }

                    // --- Client-side filtering and sorting ---
                    List<CaseModel> cases = snapshot.data!;
                    if (_filterStatus != "All") {
                      cases = cases
                          .where((c) => c.status == _filterStatus)
                          .toList();
                    }
                    if (_searchQuery.isNotEmpty) {
                      cases = cases
                          .where((c) => c.title
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase()))
                          .toList();
                    }
                    cases.sort((a, b) {
                      final DateTime aDate;
                      final DateTime bDate;
                      switch (_sortBy) {
                        case 'hearingDate':
                          aDate = a.hearingDate;
                          bDate = b.hearingDate;
                          break;
                        case 'dueDate':
                          aDate = a.dueDate;
                          bDate = b.dueDate;
                          break;
                        default:
                          aDate = a.lastUpdated;
                          bDate = b.lastUpdated;
                          break;
                      }
                      return _isSortDescending
                          ? bDate.compareTo(aDate)
                          : aDate.compareTo(bDate);
                    });

                    if (cases.isEmpty) {
                      return const EmptyState(
                          message: "No cases match your filters.");
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: cases.length,
                      itemBuilder: (context, index) {
                        // ✅ 2. WRAPPED the card in a GestureDetector for navigation
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CaseDetailScreen(caseModel: cases[index]),
                              ),
                            );
                          },
                          child: _CaseCard(caseModel: cases[index]),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET FOR A SINGLE CASE CARD ---
class _CaseCard extends StatelessWidget {
  final CaseModel caseModel;
  const _CaseCard({required this.caseModel});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black38,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white.withOpacity(0.15),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    caseModel.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                StatusPill(status: caseModel.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Court: ${caseModel.courtName}",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildDateInfo("Hearing", caseModel.hearingDate),
                _buildDateInfo("Due Date", caseModel.dueDate),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildDateInfo(String title, DateTime date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          DateFormat.yMMMd().format(date),
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// Ensure StringExtension and StatusPill are available (e.g., in common.dart)
extension StringExtension on String {
  String capitalize() =>
      "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
}
