import 'package:NyayaMitra/models/user_model';
import 'package:NyayaMitra/screens/clientSide/lawyer_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:NyayaMitra/services/db_service.dart';
import '../../../widgets/lawyer_card.dart'; // Using your custom LawyerCard for the list view

class LawyerListScreen extends StatefulWidget {
  const LawyerListScreen({super.key});

  @override
  _LawyerListScreenState createState() => _LawyerListScreenState();
}

class _LawyerListScreenState extends State<LawyerListScreen> {
  bool isGrid = true;
  final DbService _dbService = DbService();
  late Future<List<UserModel>> _lawyersFuture;

  @override
  void initState() {
    super.initState();
    _lawyersFuture = _dbService.fetchLawyers();
  }

  // ✅ THIS FUNCTION IS NOW CORRECTED
  void _viewLawyerDetails(UserModel lawyer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        // Pass the full UserModel object directly to the 'lawyer' parameter
        builder: (_) => LawyerDetailsScreen(lawyer: lawyer, lawyerData: {},),
      ),
    );
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Our Lawyers", // Updated Title
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isGrid
                            ? Icons.list_rounded
                            : Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        setState(() => isGrid = !isGrid);
                      },
                    ),
                  ],
                ),
              ),

              // --- LAWYER LIST / GRID ---
              Expanded(
                child: FutureBuilder<List<UserModel>>(
                  future: _lawyersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "No lawyers found.",
                          style:
                              TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                      );
                    }

                    final lawyers = snapshot.data!;

                    if (isGrid) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85, // Adjusted for better visuals
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: lawyers.length,
                        itemBuilder: (context, index) {
                          final lawyer = lawyers[index];
                          return _LawyerGridCard(
                            lawyer: lawyer,
                            onTap: () => _viewLawyerDetails(lawyer), onSelect: () {  }, onViewProfile: () {  },
                          );
                        },
                      );
                    } else {
                      // Use your custom LawyerCard for the list view
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: lawyers.length,
                        itemBuilder: (context, index) {
                          final lawyer = lawyers[index];
                          return LawyerCard(
                            name: lawyer.name,
                            rating: lawyer.rating,
                            specialization: lawyer.specialization ?? 'General Practice',
                            totalCases: lawyer.totalCases,
                            casesWon: lawyer.casesWon,
                            activeCases: lawyer.activeCases,
                            onTap: () => _viewLawyerDetails(lawyer),
                          );
                        },
                      );
                    }
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


class _LawyerGridCard extends StatelessWidget {
  final UserModel lawyer;
  final VoidCallback onSelect;
  final VoidCallback onViewProfile;

  const _LawyerGridCard(
      {required this.lawyer,
      required this.onSelect,
      required this.onViewProfile, required void Function() onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = lawyer.profileImage;
    final rating = lawyer.rating.toStringAsFixed(1);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onViewProfile,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: imageUrl != null
                    ? Image.network(imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person,
                                size: 60, color: Colors.white70))
                    : const Icon(Icons.person,
                        size: 60, color: Colors.white70),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lawyer.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rate_rounded,
                        color: Colors.amber.shade400, size: 16),
                    const SizedBox(width: 4),
                    Text(rating, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2575FC).withOpacity(0.8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onSelect,
              child: const Text("Select"),
            ),
          ),
        ],
      ),
    );
  }
}
