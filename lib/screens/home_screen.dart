import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../services/camera_service.dart';
import '../providers/clothing_provider.dart';
import '../widgets/camera_overlay.dart';
import '../widgets/glam_button.dart';
import 'scan_result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService.instance;
  bool _isLoading = true;
  String? _error;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await _cameraService.initialize();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Camera not available. You can still use the gallery.';
        });
      }
    }
  }

  Future<void> _takePicture() async {
    if (_isCapturing) return;
    
    setState(() {
      _isCapturing = true;
    });

    try {
      final file = await _cameraService.takePicture();
      if (file != null && mounted) {
        _navigateToResult(file);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final file = await _cameraService.pickFromGallery();
    if (file != null && mounted) {
      _navigateToResult(file);
    }
  }

  void _navigateToResult(File imageFile) {
    final provider = context.read<ClothingProvider>();
    provider.reset();
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          ScanResultScreen(imageFile: imageFile),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: Stack(
        children: [
          // Camera Preview or Placeholder
          if (_isLoading)
            _buildLoadingState()
          else if (_error != null)
            _buildErrorState()
          else
            _buildCameraPreview(),
          
          // Top Bar
          _buildTopBar(),
          
          // Bottom Controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.goldAccent),
            SizedBox(height: 24),
            Text(
              'Initializing camera...',
              style: TextStyle(color: AppTheme.softGray),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: AppTheme.softGray,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.softGray,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              GlamButton(
                onPressed: _pickFromGallery,
                icon: Icons.photo_library_outlined,
                label: 'Open Gallery',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera Preview
        ClipRRect(
          child: Transform.scale(
            scale: 1.0,
            child: Center(
              child: CameraPreview(_cameraService.controller!),
            ),
          ),
        ),
        
        // Overlay
        const CameraOverlay(),
      ],
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Logo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppTheme.primaryBlack,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'GLAM AI',
                  style: TextStyle(
                    color: AppTheme.pureWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            
            // Settings button (placeholder)
            Container(
              decoration: GlassDecoration(),
              child: IconButton(
                onPressed: () {
                  // TODO: Settings
                },
                icon: const Icon(
                  Icons.tune_rounded,
                  color: AppTheme.pureWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              AppTheme.primaryBlack.withOpacity(0.8),
              AppTheme.primaryBlack,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Hint text
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: GlassDecoration(opacity: 0.15),
              child: const Text(
                '📸 Point at a clothing item to scan',
                style: TextStyle(
                  color: AppTheme.pureWhite,
                  fontSize: 14,
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                _buildControlButton(
                  icon: Icons.photo_library_outlined,
                  label: 'Gallery',
                  onTap: _pickFromGallery,
                ),
                
                // Capture button
                GestureDetector(
                  onTap: _error == null ? _takePicture : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _error == null ? AppTheme.goldGradient : null,
                      color: _error != null ? AppTheme.softGray : null,
                      boxShadow: _error == null ? AppTheme.glowShadow : null,
                    ),
                    child: Center(
                      child: _isCapturing
                          ? const CircularProgressIndicator(
                              color: AppTheme.primaryBlack,
                              strokeWidth: 3,
                            )
                          : Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.primaryBlack,
                                  width: 3,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
                
                // Switch camera button
                _buildControlButton(
                  icon: Icons.flip_camera_ios_outlined,
                  label: 'Flip',
                  onTap: _error == null
                      ? () => _cameraService.switchCamera().then((_) => setState(() {}))
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: GlassDecoration(),
            child: Icon(
              icon,
              color: onTap != null ? AppTheme.pureWhite : AppTheme.softGray,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: onTap != null ? AppTheme.softGray : AppTheme.softGray.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
