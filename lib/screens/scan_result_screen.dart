import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/clothing_provider.dart';
import '../widgets/glam_button.dart';
import '../widgets/clothing_details_card.dart';
import '../widgets/shimmer_loading.dart';
import 'outfit_screen.dart';

class ScanResultScreen extends StatefulWidget {
  final File imageFile;

  const ScanResultScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    if (mounted) {
      context.read<ClothingProvider>().analyzeImageFromBytes(
        bytes,
        imagePath: widget.imageFile.path,
      );
    }
  }

  void _navigateToOutfits() {
    final provider = context.read<ClothingProvider>();
    provider.generateOutfits();
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const OutfitScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
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
      body: CustomScrollView(
        slivers: [
          // Image Header
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).size.height * 0.5,
            pinned: true,
            backgroundColor: AppTheme.primaryBlack,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: GlassDecoration(),
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image
                  Hero(
                    tag: 'scan_image',
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          AppTheme.primaryBlack.withOpacity(0.8),
                          AppTheme.primaryBlack,
                        ],
                        stops: const [0.0, 0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Consumer<ClothingProvider>(
              builder: (context, provider, child) {
                if (provider.isAnalyzing) {
                  return _buildAnalyzingState();
                } else if (provider.analysisState == AnalysisState.error) {
                  return _buildErrorState(provider.errorMessage);
                } else if (provider.currentItem != null) {
                  return _buildResultState(provider);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Animated icon
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 6.28,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.glowShadow,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryBlack,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Analyzing your style...',
            style: TextStyle(
              color: AppTheme.pureWhite,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our AI is identifying the clothing item',
            style: TextStyle(
              color: AppTheme.softGray,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 32),
          const ShimmerLoading(height: 120),
          const SizedBox(height: 16),
          const ShimmerLoading(height: 60),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.errorRed.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              color: AppTheme.errorRed,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Analysis Failed',
            style: TextStyle(
              color: AppTheme.pureWhite,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.softGray,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GlamButton(
                onPressed: _analyzeImage,
                icon: Icons.refresh,
                label: 'Try Again',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultState(ClothingProvider provider) {
    final item = provider.currentItem!;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: AppTheme.successGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Item Identified!',
                style: TextStyle(
                  color: AppTheme.successGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Item name
          Row(
            children: [
              Text(
                item.typeEmoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.displayName,
                      style: const TextStyle(
                        color: AppTheme.pureWhite,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      item.category.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.goldAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Details card
          ClothingDetailsCard(item: item),
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: GlamButton(
                  onPressed: _navigateToOutfits,
                  icon: Icons.auto_awesome,
                  label: 'Generate Outfits',
                  isPrimary: true,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: GlamButton(
                  onPressed: () {
                    // TODO: Implement price finder
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Price finder coming soon! 💰'),
                        backgroundColor: AppTheme.cardBackground,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  icon: Icons.local_offer_outlined,
                  label: 'Find Best Prices',
                  isPrimary: false,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
