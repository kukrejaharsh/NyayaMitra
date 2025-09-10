import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ScanDocResultScreen extends StatefulWidget {
  final File scannedFile;
  final String userId;

  const ScanDocResultScreen({Key? key, required this.scannedFile, required this.userId}) : super(key: key);

  @override
  _ScanDocResultScreenState createState() => _ScanDocResultScreenState();
}

class _ScanDocResultScreenState extends State<ScanDocResultScreen> {
  bool _loading = true;
  String? _docUrl;
  String? _geminiSummary;

  @override
  void initState() {
    super.initState();
    _processScan();
  }

  Future<void> _processScan() async {
    try {
      // 1. Upload image to Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child("scans/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}.jpg");
      await ref.putFile(widget.scannedFile);
      final url = await ref.getDownloadURL();

      // 2. Send to Gemini for analysis
      final model = GenerativeModel(
        model: 'gemini-pro-vision',
        apiKey: 'YOUR_GEMINI_API_KEY',
      );
      final prompt = TextPart("Extract key information from this document and summarize.");
      final imagePart = DataPart('image/jpeg', await widget.scannedFile.readAsBytes());

      final response = await model.generateContent([Content.multi([prompt, imagePart])]);

      // 3. Save in Firestore
      final docRef = await FirebaseFirestore.instance.collection("scanned_docs").add({
        "userId": widget.userId,
        "fileUrl": url,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
        "gemini_summary": response.text ?? "No info extracted",
      });

      setState(() {
        _loading = false;
        _docUrl = url;
        _geminiSummary = response.text;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _geminiSummary = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                Expanded(
                  flex: 5,
                  child: Image.file(widget.scannedFile, fit: BoxFit.contain),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Document Summary",
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text(_geminiSummary ?? "No summary",
                              style: TextStyle(color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text("Save", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () {
                          // TODO: Add Share logic here
                        },
                        icon: const Icon(Icons.share, color: Colors.white),
                        label: const Text("Share", style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        icon: const Icon(Icons.close, color: Colors.white),
                        label: const Text("Back", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
