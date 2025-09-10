import 'package:NyayaMitra/models/review_model';
import 'package:NyayaMitra/models/user_model';
import 'package:NyayaMitra/services/db_service.dart';
import 'package:flutter/material.dart';

class LawyerDetailsScreen extends StatefulWidget {
  final UserModel lawyer;
  // ✅ This flag controls if the 'Chat' and 'Hire' buttons are shown
  final bool showActionButtons;

  const LawyerDetailsScreen({
    Key? key,
    required this.lawyer,
    this.showActionButtons = false, required Map<String, dynamic> lawyerData, // Defaults to false
  }) : super(key: key);

  @override
  State<LawyerDetailsScreen> createState() => _LawyerDetailsScreenState();
}

class _LawyerDetailsScreenState extends State<LawyerDetailsScreen> {
  final DbService _dbService = DbService();
  late Future<List<Review>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _dbService.fetchReviewsForLawyer(widget.lawyer.userId);
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
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // --- Profile Header ---
            SliverToBoxAdapter(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    backgroundImage: widget.lawyer.profileImage != null
                        ? NetworkImage(widget.lawyer.profileImage!)
                        : null,
                    child: widget.lawyer.profileImage == null
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.lawyer.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.lawyer.specialization ?? 'General Practice',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _statCard("⭐ Rating", widget.lawyer.rating.toStringAsFixed(1)),
                        _statCard("Cases", "${widget.lawyer.totalCases}"),
                        _statCard("Won", "${widget.lawyer.casesWon}"),
                        _statCard("Active", "${widget.lawyer.activeCases}"),
                      ],
                    ),
                  ),
                   const SizedBox(height: 20),
                ],
              ),
            ),

            // --- Details & Reviews Body ---
            SliverFillRemaining(
              hasScrollBody: true,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Client Reviews", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    Expanded(
                      child: FutureBuilder<List<Review>>(
                        future: _reviewsFuture,
                        builder: (context, snapshot) {
                           if (snapshot.connectionState == ConnectionState.waiting) {
                             return const Center(child: CircularProgressIndicator());
                           }
                           if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                             return const Center(child: Text("No reviews yet."));
                           }
                           final reviews = snapshot.data!;
                           return ListView.separated(
                             padding: EdgeInsets.zero,
                             itemCount: reviews.length,
                             itemBuilder: (context, index) {
                               final review = reviews[index];
                               return _ReviewTile(review: review);
                             },
                             separatorBuilder: (_,__) => const Divider(height: 20),
                           );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      // ✅ Action buttons are now conditional
      bottomNavigationBar: widget.showActionButtons ? _buildActionButtons() : null,
    );
  }

  Widget _statCard(String title, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20).copyWith(bottom: 30),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.chat_bubble_outline_rounded),
              label: const Text("Chat"),
              onPressed: () { /* TODO: Implement Chat action */ },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              icon: const Icon(Icons.assignment_turned_in_outlined),
              label: const Text("Hire"),
              onPressed: () { /* TODO: Implement Hire action */ },
            ),
          ),
        ],
      ),
    );
  }
}

// A dedicated widget to display a single review
class _ReviewTile extends StatelessWidget {
  final Review review;
  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    // We can use another FutureBuilder to fetch the client's name
    return FutureBuilder<UserModel?>(
      future: DbService().getUserProfile(review.clientId),
      builder: (context, snapshot) {
        final clientName = snapshot.data?.name ?? "Anonymous Client";
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle, size: 40, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        )),
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment, style: TextStyle(color: Colors.grey[700])),
          ],
        );
      }
    );
  }
}
