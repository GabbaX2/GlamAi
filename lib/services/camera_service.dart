import 'dart:io';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class CameraService {
  static CameraService? _instance;
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  CameraService._();

  static CameraService get instance {
    _instance ??= CameraService._();
    return _instance!;
  }

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized && (_controller?.value.isInitialized ?? false);
  List<CameraDescription>? get cameras => _cameras;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        throw Exception('No cameras available');
      }

      // Use the back camera by default
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _isInitialized = true;
    } catch (e) {
      print('Error initializing camera: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    final currentDirection = _controller?.description.lensDirection;
    final newCamera = _cameras!.firstWhere(
      (camera) => camera.lensDirection != currentDirection,
      orElse: () => _cameras!.first,
    );

    await _controller?.dispose();
    _controller = CameraController(
      newCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    await _controller!.initialize();
  }

  Future<File?> takePicture() async {
    if (!isInitialized) return null;

    try {
      final XFile photo = await _controller!.takePicture();
      
      // Save to app documents
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${directory.path}/glam_ai_$timestamp.jpg';
      
      final File savedFile = await File(photo.path).copy(newPath);
      return savedFile;
    } catch (e) {
      print('Error taking picture: $e');
      return null;
    }
  }

  Future<File?> pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Copy to app documents
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${directory.path}/glam_ai_$timestamp.jpg';
      
      final File savedFile = await File(image.path).copy(newPath);
      return savedFile;
    } catch (e) {
      print('Error picking from gallery: $e');
      return null;
    }
  }

  void dispose() {
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }
}
