import 'dart:io';
import 'package:flutter/material.dart';

class ScanPreviewScreen extends StatelessWidget {
  final String imagePath;
  const ScanPreviewScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.file(File(imagePath), fit: BoxFit.contain),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Cross button
                  FloatingActionButton(
                    heroTag: "cross",
                    backgroundColor: Colors.red,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 32, color: Colors.white),
                  ),
                  // Tick button
                  FloatingActionButton(
                    heroTag: "tick",
                    backgroundColor: Colors.green,
                    onPressed: () {
                      // ✅ Confirm & proceed
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Image Confirmed!")),
                      );
                      Navigator.pop(context, imagePath); // return the path
                    },
                    child: const Icon(Icons.check, size: 32, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
