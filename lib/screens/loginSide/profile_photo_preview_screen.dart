import 'dart:io';
import 'package:flutter/material.dart';

/// ✅ Preview screen to confirm profile photo before upload (now with loading state)
class ProfilePhotoPreviewScreen extends StatefulWidget {
  final File imageFile;
  final Future<void> Function(File) onConfirm;

  const ProfilePhotoPreviewScreen({
    super.key,
    required this.imageFile,
    required this.onConfirm,
  });

  @override
  State<ProfilePhotoPreviewScreen> createState() =>
      _ProfilePhotoPreviewScreenState();
}

class _ProfilePhotoPreviewScreenState extends State<ProfilePhotoPreviewScreen> {
  // ✅ State variable to track the upload process
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Image.file(widget.imageFile, fit: BoxFit.contain)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // "Retake" button remains the same
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent),
                  // ✅ Disable the button during upload
                  onPressed: _isUploading ? null : () => Navigator.pop(context),
                  child: const Text("Retake"),
                ),

                // "Use Photo" button is now stateful
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, minimumSize: const Size(120, 40)),
                  // ✅ Disable button during upload and handle the async operation
                  onPressed: _isUploading
                      ? null
                      : () async {
                          // 1. Show the loading indicator
                          setState(() {
                            _isUploading = true;
                          });

                          try {
                            // 2. Call the upload function passed from ProfileScreen
                            await widget.onConfirm(widget.imageFile);

                            // 3. If successful, close the preview screen
                            if (context.mounted) Navigator.pop(context);
                          } catch (e) {
                            // Optional: Show an error if upload fails
                            if(context.mounted){
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Upload failed: $e"))
                              );
                            }
                          } finally {
                            // 4. In case of error, re-enable the button
                             if(mounted){
                               setState(() {
                                _isUploading = false;
                               });
                             }
                          }
                        },
                  // ✅ Show a loading spinner or the text
                  child: _isUploading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Use Photo"),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}