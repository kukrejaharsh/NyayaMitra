import 'package:NyayaMitra/models/case_model';
import 'package:NyayaMitra/models/chat_model';
import 'package:NyayaMitra/models/review_model';
import 'package:NyayaMitra/models/user_model';
import 'package:cloud_firestore/cloud_firestore.dart';


class DbException implements Exception {
  final String message;
  DbException(this.message);
  @override
  String toString() => message;
}

class DbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔹 COLLECTION REFERENCES
  CollectionReference get usersRef => _db.collection('users');
  CollectionReference get casesRef => _db.collection('cases');
  CollectionReference get chatsRef => _db.collection('chats');
  CollectionReference get reviewsRef => _db.collection('reviews');

  // ================= USERS =================

  /// Fetches a single user's profile by their UID.
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await usersRef.doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw DbException("Failed to fetch user profile: $e");
    }
  }

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await usersRef.doc(user.userId).update(user.toMap());
    } catch (e) {
      throw DbException("Failed to update user profile: $e");
    }
  }

  // ================= CASES =================

  Future<void> createCase({
    required String currentUserId,
    required String title,
    required String description,
    required String caseType,
    String? applicableSections,
    required String courtName,
    DateTime? dueDate,
    DateTime? hearingDate,
    String priority = "medium",
    String? chosenLawyerId,
  }) async {
    try {
      final caseDoc = casesRef.doc();
      final caseModel = CaseModel(
        caseId: caseDoc.id,
        title: title,
        description: description,
        caseType: caseType,
        applicableSections: applicableSections,
        courtName: courtName,
        clientId: currentUserId,
        lawyerId: chosenLawyerId,
        status: "pending",
        lawyerRequestStatus: chosenLawyerId == null ? "none" : "sent",
        createdAt: DateTime.now(),
        dueDate: dueDate ?? DateTime.now(),
        hearingDate: hearingDate ?? DateTime.now(),
        lastUpdated: DateTime.now(),
        priority: priority,
      );
      await caseDoc.set(caseModel.toMap());
    } catch (e) {
      throw DbException("Failed to create case: $e");
    }
  }
  
  /// Fetches all cases associated with a user, either as a client or a lawyer.
  Future<List<CaseModel>> fetchClientCases(String userId) async {
    try {
      final clientCasesQuery = casesRef.where("clientId", isEqualTo: userId);
      final lawyerCasesQuery = casesRef.where("lawyerId", isEqualTo: userId);

      final clientCasesSnapshot = await clientCasesQuery.get();
      final lawyerCasesSnapshot = await lawyerCasesQuery.get();
      
      final allDocs = [...clientCasesSnapshot.docs, ...lawyerCasesSnapshot.docs];
      final uniqueDocs = { for (var doc in allDocs) doc.id : doc }.values.toList();

      return uniqueDocs
          .map((doc) => CaseModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DbException("Failed to fetch user cases: $e");
    }
  }

  Future<void> sendLawyerRequest({
    required String caseId,
    required String lawyerId,
  }) async {
    try {
      await casesRef.doc(caseId).update({
        "lawyerId": lawyerId,
        "lawyerRequestStatus": "sent",
        "requestSentAt": FieldValue.serverTimestamp(),
        "lastUpdated": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw DbException("Failed to send lawyer request: $e");
    }
  }

  Future<void> updateLawyerRequest({
    required String caseId,
    required String status, // "accepted" | "rejected"
  }) async {
    try {
      await casesRef.doc(caseId).update({
        "lawyerRequestStatus": status,
        "lastUpdated": FieldValue.serverTimestamp(),
      });

      if (status == "accepted") {
        final caseSnap = await casesRef.doc(caseId).get();
        if (caseSnap.exists) {
          final data = caseSnap.data() as Map<String, dynamic>;
          final lawyerId = data["lawyerId"];
          if (lawyerId != null) {
            await usersRef.doc(lawyerId).update({
              "totalCases": FieldValue.increment(1),
              "activeCases": FieldValue.increment(1),
            });
          }
        }
      }
    } catch (e) {
      throw DbException("Failed to update lawyer request: $e");
    }
  }

  Future<void> updateCaseStatus({
    required String caseId,
    required String status,
    required String lawyerId,
  }) async {
    try {
      await casesRef.doc(caseId).update({
        "status": status,
        "lastUpdated": FieldValue.serverTimestamp(),
      });

      if (status == "closed") {
        await usersRef.doc(lawyerId).update({
          "activeCases": FieldValue.increment(-1),
        });
      }

      if (status == "won") {
        await usersRef.doc(lawyerId).update({
          "casesWon": FieldValue.increment(1),
          "activeCases": FieldValue.increment(-1),
        });
      }
    } catch (e) {
      throw DbException("Failed to update case status: $e");
    }
  }

  // ================= CHATS =================

  /// Streams all messages for a specific case, ordered by time.
  Stream<List<ChatMessage>> streamMessagesForCase(String caseId) {
    // ✅ UPDATED: Now orders by 'timestamp' to match your model
    return chatsRef
        .where('caseId', isEqualTo: caseId)
        .orderBy('timestamp', descending: true) 
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Fetches the most recent message for every case the user is involved in.
  Stream<List<ChatMessage>> streamConversations(String userId) {
    // ✅ UPDATED: Now orders by 'timestamp' to match your model
    return chatsRef
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) {
        final allMessages = snapshot.docs
            .map((doc) => ChatMessage.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .where((msg) => msg.senderId == userId || msg.receiverId == userId)
            .toList();
        
        final latestMessages = <String, ChatMessage>{};
        for (var msg in allMessages) {
          if (!latestMessages.containsKey(msg.caseId)) {
            latestMessages[msg.caseId] = msg;
          }
        }
        return latestMessages.values.toList();
      });
  }
  
  Future<void> markMessageRead(String msgId) async {
    try {
      await chatsRef.doc(msgId).update({"isRead": true});
    } catch (e) {
      throw DbException("Failed to mark message as read: $e");
    }
  }

  
  Future<void> sendMessage(ChatMessage message) async {
    try {
      await chatsRef.doc(message.msgId).set(message.toMap());
    } catch (e) {
      throw DbException("Failed to send message: $e");
    }
  }

  // ================= REVIEWS =================

  Future<void> addReview(Review review) async {
    try {
      await reviewsRef.doc(review.reviewId).set(review.toMap());

      final lawyerDoc = await usersRef.doc(review.lawyerId).get();
      if (!lawyerDoc.exists) throw DbException("Lawyer not found.");

      final lawyerData = lawyerDoc.data() as Map<String, dynamic>;
      int ratingsCount = (lawyerData["ratingsCount"] ?? 0) + 1;
      double oldRating = (lawyerData["rating"] ?? 0.0);
      double newRating =
          ((oldRating * (ratingsCount - 1)) + review.rating) / ratingsCount;

      await usersRef.doc(review.lawyerId).update({
        "rating": newRating,
        "ratingsCount": ratingsCount,
      });
    } catch (e) {
      throw DbException("Failed to add review: $e");
    }
  }
  
  Future<List<Review>> fetchReviewsForLawyer(String lawyerId) async {
    try {
      final snapshot = await reviewsRef
          .where("lawyerId", isEqualTo: lawyerId)
          .orderBy("createdAt", descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        return [];
      }
      
      return snapshot.docs
          .map((doc) => Review.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

    } catch (e) {
      throw DbException("Failed to fetch reviews: $e");
    }
  }

  // ================= LAWYERS =================

  Future<List<UserModel>> fetchLawyers() async {
    try {
      final snapshot = await usersRef.where("role", isEqualTo: "lawyer").get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw DbException("Failed to fetch lawyers: $e");
    }
  }
  
  // --- LAWYER DASHBOARD QUERIES ---

  /// Fetches cases where a lawyer has been requested but hasn't responded.
  Stream<List<CaseModel>> fetchCaseRequests(String lawyerId) {
    return casesRef
        .where("lawyerId", isEqualTo: lawyerId)
        .where("lawyerRequestStatus", isEqualTo: "sent")
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CaseModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Fetches cases that a lawyer has accepted and are ongoing.
  Stream<List<CaseModel>> fetchActiveCases(String lawyerId) {
    return casesRef
        .where("lawyerId", isEqualTo: lawyerId)
        .where("status", isEqualTo: "active")
        .orderBy("lastUpdated", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CaseModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Fetches cases that a lawyer has completed.
  Stream<List<CaseModel>> fetchClosedCases(String lawyerId) {
    return casesRef
        .where("lawyerId", isEqualTo: lawyerId)
        .where("status", whereIn: ["closed", "won"])
        .orderBy("lastUpdated", descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CaseModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }
}

