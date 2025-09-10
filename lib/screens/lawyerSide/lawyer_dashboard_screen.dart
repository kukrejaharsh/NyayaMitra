import 'dart:ui';
import 'package:NyayaMitra/chat_screen.dart';
import 'package:NyayaMitra/models/case_model';
import 'package:NyayaMitra/models/user_model';
import 'package:NyayaMitra/screens/clientSide/case_detail_screen.dart';
import 'package:NyayaMitra/services/db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LawyerDashboardScreen extends StatefulWidget {
  const LawyerDashboardScreen({super.key});

  @override
  State<LawyerDashboardScreen> createState() => _LawyerDashboardScreenState();
}

class _LawyerDashboardScreenState extends State<LawyerDashboardScreen> {
  final DbService _dbService = DbService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;
  late Future<UserModel?> _lawyerProfileFuture;
  int _currentIndex = 0; // For the bottom nav bar

  @override
  void initState() {
    super.initState();
    // ✅ FIX: Corrected method name from getUserProfile to getUser
    _lawyerProfileFuture = _dbService.getUserProfile(userId);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    automaticallyImplyLeading: false,
                    title: const Text("Dashboard",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    actions: [
                      IconButton(
                        onPressed: () {
                          /* TODO: Navigate to notifications screen */
                        },
                        icon: const Icon(Icons.notifications_none_rounded),
                      )
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: FutureBuilder<UserModel?>(
                      future: _lawyerProfileFuture,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const SizedBox(
                              height: 200); // Placeholder height
                        }
                        return _LawyerStatsHeader(lawyer: snapshot.data!);
                      },
                    ),
                  ),
                  SliverPersistentHeader(
                    delegate: _StickyTabBarDelegate(
                      const TabBar(
                        // ✅ UI UPDATE: Enhanced tab text color for visibility
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white70,
                        indicatorColor: Colors.white,
                        indicatorWeight: 3.0,
                        tabs: [
                          Tab(text: "Requests"),
                          Tab(text: "Active Cases"),
                          Tab(text: "History"),
                        ],
                      ),
                    ),
                    pinned: true,
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  _CaseListTab(
                      stream: _dbService.fetchCaseRequests(userId),
                      isRequestTab: true),
                  _CaseListTab(stream: _dbService.fetchActiveCases(userId)),
                  _CaseListTab(stream: _dbService.fetchClosedCases(userId)),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _LawyerBottomNav(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 0) return;
            if (index == 1) Navigator.pushNamed(context, '/all-chats');
            if (index == 2) Navigator.pushNamed(context, '/profile');
          },
        ),
      ),
    );
  }
}

// --- HEADER WIDGET ---
class _LawyerStatsHeader extends StatelessWidget {
  final UserModel lawyer;
  const _LawyerStatsHeader({required this.lawyer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
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
        child: Column(
          children: [
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: CircleAvatar(
                radius: 45,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: lawyer.profileImage != null
                    ? NetworkImage(lawyer.profileImage!)
                    : null,
                child: lawyer.profileImage == null
                    ? const Icon(Icons.person, size: 45, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 12),
            Text(lawyer.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                    value: lawyer.rating.toStringAsFixed(1),
                    label: "Rating",
                    icon: Icons.star_rounded,
                    color: Colors.white),
                _StatItem(
                    value: lawyer.activeCases.toString(),
                    label: "Active",
                    icon: Icons.work_history_rounded,
                    color: Colors.white),
                _StatItem(
                    value: lawyer.casesWon.toString(),
                    label: "Won",
                    icon: Icons.emoji_events_rounded,
                    color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- TAB CONTENT WIDGET ---
class _CaseListTab extends StatelessWidget {
  final Stream<List<CaseModel>> stream;
  final bool isRequestTab;

  const _CaseListTab({required this.stream, this.isRequestTab = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<CaseModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
              child: Text("No cases found in this category.",
                  style: TextStyle(color: Colors.white70, fontSize: 16)));
        }
        final cases = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: cases.length,
          itemBuilder: (context, index) {
            final caseItem = cases[index];
            return isRequestTab
                ? _CaseRequestCard(caseModel: caseItem)
                : _CaseListCard(caseModel: caseItem);
          },
        );
      },
    );
  }
}

class _CaseRequestCard extends StatefulWidget {
  final CaseModel caseModel;
  const _CaseRequestCard({required this.caseModel});

  @override
  State<_CaseRequestCard> createState() => _CaseRequestCardState();
}

class _CaseRequestCardState extends State<_CaseRequestCard> {
  final DbService _dbService = DbService();
  late Future<UserModel?> _clientFuture;

  @override
  void initState() {
    super.initState();
    // ✅ FIX: Corrected method name from getUserProfile to getUser
    _clientFuture = _dbService.getUserProfile(widget.caseModel.clientId);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.caseModel.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(widget.caseModel.caseType,
                style: const TextStyle(color: Colors.white70)),
            const Divider(color: Colors.white30, height: 24),
            FutureBuilder<UserModel?>(
              future: _clientFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const SizedBox(
                      height: 40,
                      child: Center(child: LinearProgressIndicator()));
                final client = snapshot.data!;
                return Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: client.profileImage != null
                              ? NetworkImage(client.profileImage!)
                              : null,
                          child: client.profileImage == null
                              ? const Icon(Icons.person, size: 20)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(client.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                        const Spacer(),
                        OutlinedButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => CaseDetailScreen(
                                      caseModel: widget.caseModel))),
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white38)),
                          child: const Text("Details",
                              style: TextStyle(color: Colors.white70)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                            onPressed: () => _dbService.updateLawyerRequest(
                                caseId: widget.caseModel.caseId,
                                status: 'rejected'),
                            child: const Text("Reject",
                                style: TextStyle(color: Colors.redAccent))),
                        const SizedBox(width: 8),
                        ElevatedButton(
                            onPressed: () => _dbService.updateLawyerRequest(
                                caseId: widget.caseModel.caseId,
                                status: 'accepted'),
                            child: const Text("Accept")),
                      ],
                    )
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CaseListCard extends StatefulWidget {
  final CaseModel caseModel;
  const _CaseListCard({required this.caseModel});

  @override
  State<_CaseListCard> createState() => _CaseListCardState();
}

class _CaseListCardState extends State<_CaseListCard> {
  final DbService _dbService = DbService();
  late Future<UserModel?> _clientFuture;

  @override
  void initState() {
    super.initState();
    _clientFuture = _dbService.getUserProfile(widget.caseModel.clientId);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CaseDetailScreen(caseModel: widget.caseModel))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.caseModel.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                        "Hearing: ${DateFormat.yMMMd().format(widget.caseModel.hearingDate)}",
                        style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              FutureBuilder<UserModel?>(
                  future: _clientFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData)
                      return const SizedBox(
                          width: 48); // Placeholder for button
                    final client = snapshot.data!;
                    return IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded,
                          color: Colors.white70),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                      caseId: widget.caseModel.caseId,
                                      recipientId: client.userId,
                                      recipientName: client.name,
                                      recipientAvatarUrl:
                                          client.profileImage ?? '',
                                    )));
                      },
                      tooltip: "Open Chat",
                    );
                  })
            ],
          ),
        ),
      ),
    );
  }
}

// --- OTHER HELPER WIDGETS ---

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  const _StatItem(
      {required this.value,
      required this.label,
      required this.icon,
      required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 4),
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color))
      ]),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14))
    ]);
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate(this.tabBar);
  final TabBar tabBar;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          color: Colors.black.withOpacity(0.2),
          child: tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class _LawyerBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _LawyerBottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF171A2A),
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white60,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
        BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded), label: "Chats"),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: "Profile"),
      ],
    );
  }
}
