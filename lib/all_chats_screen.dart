import 'package:NyayaMitra/models/chat_model';
import 'package:NyayaMitra/models/user_model';
import 'package:NyayaMitra/services/db_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'chat_screen.dart';

class AllChatsScreen extends StatefulWidget {
  const AllChatsScreen({Key? key}) : super(key: key);

  @override
  State<AllChatsScreen> createState() => _AllChatsScreenState();
}

class _AllChatsScreenState extends State<AllChatsScreen> {
  final DbService _dbService = DbService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
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
                    const Text("All Chats",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // --- SEARCH BAR ---
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search by name or case...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                    prefixIcon: const Icon(Icons.search, color: Colors.white),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.2),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              // --- CHAT LIST ---
              Expanded(
                child: StreamBuilder<List<ChatMessage>>(
                  stream: _dbService.streamConversations(_currentUserId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child:
                              CircularProgressIndicator(color: Colors.white));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("You have no active chats.",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16)),
                      );
                    }
                    final conversations = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final lastMessage = conversations[index];
                        return _ConversationCard(
                          lastMessage: lastMessage,
                          searchQuery: _searchQuery,
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

class _ConversationCard extends StatelessWidget {
  final ChatMessage lastMessage;
  final String searchQuery;
  final DbService _dbService = DbService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;

  _ConversationCard({required this.lastMessage, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final otherUserId = lastMessage.senderId == _currentUserId
        ? lastMessage.receiverId
        : lastMessage.senderId;

    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        // ✅ FIX: Correctly calls getUser
        _dbService.getUserProfile(otherUserId),
        _dbService.casesRef.doc(lastMessage.caseId).get(),
      ]).then((responses) => {
            'user': responses[0],
            'case': responses[1],
          }),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox
              .shrink(); // Show nothing while loading individual cards
        }

        final UserModel? otherUser = snapshot.data!['user'];
        final caseDoc = snapshot.data!['case'] as DocumentSnapshot;

        // Handle cases where the user or case might have been deleted
        if (otherUser == null || !caseDoc.exists) {
          return const SizedBox.shrink();
        }

        final caseTitle =
            (caseDoc.data() as Map<String, dynamic>)['title'] ?? 'Unknown Case';
        final recipientName = otherUser.name;
        final recipientAvatarUrl = otherUser.profileImage ?? '';

        // Apply search filter
        if (searchQuery.isNotEmpty &&
            !recipientName.toLowerCase().contains(searchQuery.toLowerCase()) &&
            !caseTitle.toLowerCase().contains(searchQuery.toLowerCase())) {
          return const SizedBox.shrink();
        }

        final bool isUnread =
            !lastMessage.isRead && lastMessage.senderId != _currentUserId;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: recipientAvatarUrl.isNotEmpty
                  ? NetworkImage(recipientAvatarUrl)
                  : null,
              child: recipientAvatarUrl.isEmpty
                  ? const Icon(Icons.person, size: 28, color: Colors.white70)
                  : null,
            ),
            title: Text(
              recipientName,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
            subtitle: Text(
              "Case: $caseTitle\n${lastMessage.message}",
              style: TextStyle(color: isUnread ? Colors.white : Colors.white70),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  DateFormat('h:mm a').format(lastMessage.timestamp),
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                if (isUnread) ...[
                  const SizedBox(height: 4),
                  const CircleAvatar(
                      radius: 5, backgroundColor: Colors.greenAccent),
                ]
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    caseId: lastMessage.caseId,
                    recipientId: otherUserId,
                    recipientName: recipientName,
                    recipientAvatarUrl: recipientAvatarUrl,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
