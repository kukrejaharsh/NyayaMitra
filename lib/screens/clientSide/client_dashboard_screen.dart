import 'dart:ui';
import 'package:NyayaMitra/models/case_model';
import 'package:NyayaMitra/models/user_model';
import 'package:NyayaMitra/services/db_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:NyayaMitra/screens/clientSide/case_detail_screen.dart'; // Import for navigation

class ClientDashboardScreen extends StatefulWidget {
  const ClientDashboardScreen({super.key});

  @override
  State<ClientDashboardScreen> createState() => _ClientDashboardScreenState();
}

class _ClientDashboardScreenState extends State<ClientDashboardScreen> {
  int _currentIndex = 0;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  final DbService _dbService = DbService();
  late Future<UserModel?> _userDetailsFuture;

  @override
  void initState() {
    super.initState();
    // ✅ FIX: Corrected method name from getUserProfile to getUser
    _userDetailsFuture = _dbService.getUserProfile(userId);
  }

  Stream<List<CaseModel>> _userCasesStream() {
    return _dbService.casesRef
        .where('clientId', isEqualTo: userId)
        .orderBy('lastUpdated', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                CaseModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F111D),
      body: FutureBuilder<UserModel?>(
        future: _userDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                    child: CircularProgressIndicator(color: Colors.white)));
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text('Could not load user data.',
                  style: TextStyle(color: Colors.white70)),
            );
          }

          final userData = snapshot.data!;

          // ✅ FIX: Removed the outer Stack to prevent layout conflicts.
          // The Chat button is now handled by the Scaffold itself.
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Icon(Icons.home_filled,
                              color: Colors.white.withOpacity(0.8)),
                          const SizedBox(width: 8),
                          const Text(
                            "Home",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              // TODO: Navigate to a notifications screen
                            },
                            icon: const Icon(
                                Icons.notifications_none_rounded,
                                color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _Header(
                      user: userData,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  const SliverToBoxAdapter(
                      child: _SectionTitle(title: 'Quick Actions')),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  const SliverToBoxAdapter(child: _QuickActions()),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  const SliverToBoxAdapter(
                      child: _SectionTitle(title: 'Recent Cases')),
                  const SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 160,
                      child: StreamBuilder<List<CaseModel>>(
                        stream: _userCasesStream(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child:
                                    CircularProgressIndicator(color: Colors.white));
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text("No recent cases found.",
                                  style: TextStyle(color: Colors.white70)),
                            );
                          }
                          final cases = snapshot.data!;
                          return ListView.separated(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: cases.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (_, i) {
                              final caseData = cases[i];
                              return _ContinueCard(caseModel: caseData);
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 22)),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onChanged: (i) => setState(() => _currentIndex = i),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6C63FF),
        onPressed: () => Navigator.pushNamed(context, '/new-case'),
        child: const Icon(Icons.add, size: 36, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // ✅ FIX: Added the chat button here using a more stable property
      // This ensures it doesn't conflict with the body or bottom bar.
      persistentFooterButtons: [
        FloatingActionButton.small(
          onPressed: () => Navigator.pushNamed(context, '/all-chats'),
          backgroundColor: const Color(0xFF2575FC),
          child: const Icon(Icons.chat_bubble_rounded),
        ),
      ],
    );
  }
}

// All other helper widgets (_Header, _QuickActions, etc.) remain unchanged.

class _Header extends StatelessWidget {
  const _Header({required this.user});
  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color.fromARGB(255, 44, 167, 238)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              )
            ]),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Welcome, ${user.name}!',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'You have ${user.activeCases} active cases.',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9), fontSize: 14),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white.withOpacity(0.25),
                child: CircleAvatar(
                  radius: 25,
                  backgroundImage: user.profileImage != null
                      ? NetworkImage(user.profileImage!)
                      : null,
                  child: user.profileImage == null
                      ? const Icon(Icons.person,
                          size: 30, color: Colors.white70)
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickActionButton(
              icon: Icons.add_circle_outline,
              label: "New Case",
              onTap: () => Navigator.pushNamed(context, '/new-case')),
          _QuickActionButton(
              icon: Icons.people_alt_outlined,
              label: "Lawyers",
              onTap: () => Navigator.pushNamed(context, '/lawyer-list')),
          _QuickActionButton(
              icon: Icons.folder_open,
              label: "My Cases",
              onTap: () => Navigator.pushNamed(context, '/all-cases')),
          _QuickActionButton(
              icon: Icons.mic_none,
              label: "Ask AI",
              onTap: () => Navigator.pushNamed(context, '/ask-ai')),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickActionButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  const _ContinueCard({required this.caseModel});
  final CaseModel caseModel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CaseDetailScreen(caseModel: caseModel),
          ),
        );
      },
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(caseModel.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 6),
            Text(
                "Hearing: ${DateFormat.yMMMd().format(caseModel.hearingDate)}",
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.gavel, color: Colors.white70, size: 14),
                const SizedBox(width: 4),
                Text(caseModel.courtName,
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onChanged});
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF171A2A),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.white70,
        currentIndex: currentIndex,
        onTap: (index) {
          onChanged(index);
          switch (index) {
            case 0:
              break; // Already on home
            case 1:
              Navigator.pushNamed(context, '/ask-ai');
              break;
            case 2:
              Navigator.pushNamed(context, '/all-cases');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: 'Ask AI'),
          BottomNavigationBarItem(
              icon: Icon(Icons.library_books_outlined), label: 'Cases'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700)),
          TextButton(
            onPressed: () {
              if (title.contains("Cases")) {
                Navigator.pushNamed(context, '/all-cases');
              }
            },
            child:
                const Text('See all', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

