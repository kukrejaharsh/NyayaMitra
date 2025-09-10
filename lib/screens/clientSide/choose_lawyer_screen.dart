import 'package:NyayaMitra/models/user_model';
import 'package:flutter/material.dart';
import 'package:NyayaMitra/services/db_service.dart';
import 'lawyer_detail_screen.dart';

class ChooseLawyerScreen extends StatefulWidget {
  const ChooseLawyerScreen({super.key});

  @override
  _ChooseLawyerScreenState createState() => _ChooseLawyerScreenState();
}

class _ChooseLawyerScreenState extends State<ChooseLawyerScreen> {
  bool isGrid = true;
  final DbService _dbService = DbService();
  late Future<List<UserModel>> _lawyersFuture;

  @override
  void initState() {
    super.initState();
    _lawyersFuture = _dbService.fetchLawyers();
  }

  void _selectLawyer(UserModel lawyer) {
    Navigator.pop(context, lawyer.toMap());
  }

  // ✅ CORRECTED: This function now correctly passes parameters to the details screen
  void _viewLawyerDetails(UserModel lawyer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LawyerDetailsScreen(
          lawyer: lawyer,
          showActionButtons: true, lawyerData: {}, // Show "Hire" and "Chat" buttons
        ),
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
                      icon:
                          const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      "Choose a Lawyer",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        isGrid ? Icons.list_rounded : Icons.grid_view_rounded,
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
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }
                    if (snapshot.hasError ||
                        !snapshot.hasData ||
                        snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          "No lawyers found.",
                          style: TextStyle(color: Colors.white70, fontSize: 16),
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
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: lawyers.length,
                        itemBuilder: (context, index) {
                          final lawyer = lawyers[index];
                          return _LawyerGridCard(
                            lawyer: lawyer,
                            onSelect: () => _selectLawyer(lawyer),
                            onViewProfile: () => _viewLawyerDetails(lawyer),
                          );
                        },
                      );
                    } else {
                      // Use the new, themed list card
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: lawyers.length,
                        itemBuilder: (context, index) {
                          final lawyer = lawyers[index];
                          return _LawyerListCard(
                            lawyer: lawyer,
                            onSelect: () => _selectLawyer(lawyer),
                            onViewProfile: () => _viewLawyerDetails(lawyer),
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

// ✅ NEW: Redesigned list card to match the app's "glass" theme.
class _LawyerListCard extends StatelessWidget {
  final UserModel lawyer;
  final VoidCallback onSelect;
  final VoidCallback onViewProfile;

  const _LawyerListCard({
    required this.lawyer,
    required this.onSelect,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onViewProfile, // Tapping the card body shows details
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  backgroundImage: lawyer.profileImage != null
                      ? NetworkImage(lawyer.profileImage!)
                      : null,
                  child: lawyer.profileImage == null
                      ? const Icon(Icons.person,
                          size: 30, color: Colors.white70)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lawyer.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lawyer.specialization ?? 'General Practice',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2575FC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: onSelect, // Button specifically for selecting
                  child: const Text("Select"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Grid Card remains the same as the previous version.
class _LawyerGridCard extends StatelessWidget {
  final UserModel lawyer;
  final VoidCallback onSelect;
  final VoidCallback onViewProfile;

  const _LawyerGridCard(
      {required this.lawyer,
      required this.onSelect,
      required this.onViewProfile});

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
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: imageUrl != null
                    ? Image.network(imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person,
                                size: 60, color: Colors.white70))
                    : const Icon(Icons.person, size: 60, color: Colors.white70),
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
