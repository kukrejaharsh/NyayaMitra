import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addCase(Map<String, dynamic> caseData) async {
    try {
      await _db.collection('cases').add(caseData);
    } catch (e) {
      print('Error adding case: $e');
    }
  }

  Stream<QuerySnapshot> getCases() {
    return _db.collection('cases').snapshots();
  }
}
