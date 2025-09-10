import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:NyayaMitra/screens/scan_preview_screen.dart';
import 'package:torch_light/torch_light.dart';
import 'package:image_picker/image_picker.dart';

class ScanDocScreen extends StatefulWidget {
  const ScanDocScreen({super.key});

  @override
  State<ScanDocScreen> createState() => _ScanDocScreenState();
}

class _ScanDocScreenState extends State<ScanDocScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _controller;
  bool _isTorchOn = false;
  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initCamera();

    // Laser animation controller
    _animController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _animation = Tween<double>(begin: -150, end: 150).animate(_animController);
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
    );

    _controller = CameraController(backCamera, ResolutionPreset.high);
    await _controller?.initialize();
    setState(() {});
  }

  Future<void> _toggleTorch() async {
    try {
      if (_isTorchOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }
      setState(() => _isTorchOn = !_isTorchOn);
    } catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ScanPreviewScreen(imagePath: pickedFile.path),
        ),
      );
    }
  }

  Future<void> _captureImage() async {
    if (_controller != null && _controller!.value.isInitialized) {
      final file = await _controller!.takePicture();
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ScanPreviewScreen(imagePath: file.path),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Scan Document"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _controller == null || !_controller!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                CameraPreview(_controller!),

                // Overlay scanner frame + animated laser
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 250,
                    height: 300,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.deepPurpleAccent, width: 3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            return Positioned(
                              top: 150 + _animation.value,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 2,
                                color: Colors.deepPurpleAccent,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Controls
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.photo_library,
                              color: Colors.white, size: 36),
                          onPressed: _pickFromGallery,
                        ),
                        ElevatedButton(
                          onPressed: _captureImage,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 36, color: Colors.white),
                        ),
                        IconButton(
                          icon: Icon(
                            _isTorchOn ? Icons.flash_on : Icons.flash_off,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: _toggleTorch,
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
