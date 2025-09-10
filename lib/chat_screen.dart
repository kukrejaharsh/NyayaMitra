import 'package:NyayaMitra/models/chat_model';
import 'package:NyayaMitra/services/db_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  final String caseId;
  final String recipientId;
  final String recipientName;
  final String recipientAvatarUrl;

  const ChatScreen({
    Key? key,
    required this.caseId,
    required this.recipientId,
    required this.recipientName,
    required this.recipientAvatarUrl,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DbService _dbService = DbService();
  final String _currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // ✅ UPDATED: Now creates a ChatMessage using your exact model structure
    final message = ChatMessage(
      msgId: const Uuid().v4(),
      caseId: widget.caseId,
      senderId: _currentUserId,
      receiverId: widget.recipientId,
      message: _messageController.text.trim(), // Uses 'message'
      timestamp: DateTime.now(), // Uses 'timestamp'
      messageType: 'text', // Sets the message type
    );

    _dbService.sendMessage(message);
    _messageController.clear();
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        foregroundColor: Colors.black87,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(widget.recipientAvatarUrl),
              child: widget.recipientAvatarUrl.isEmpty ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 12),
            Text(widget.recipientName, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<ChatMessage>>(
                stream: _dbService.streamMessagesForCase(widget.caseId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text("No messages yet. Say hello!", style: TextStyle(color: Colors.white70)),
                    );
                  }
                  final messages = snapshot.data!;
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == _currentUserId;
                      return _ChatMessageBubble(message: msg, isMe: isMe);
                    },
                  );
                },
              ),
            ),
            _buildMessageInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  border: InputBorder.none,
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _ChatMessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2575FC) : Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(20),
          ),
        ),
        child: Text(
          // ✅ UPDATED: Now uses 'message.message' to display the text
          message.message,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }
}

