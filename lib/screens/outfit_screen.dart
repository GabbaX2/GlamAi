import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/clothing_provider.dart';
import '../widgets/outfit_card.dart';
import '../widgets/shimmer_loading.dart';

class OutfitScreen extends StatelessWidget {
  const OutfitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryBlack,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'AI Outfits',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Consumer<ClothingProvider>(
        builder: (context, provider, child) {
          if (provider.isGeneratingOutfits) {
            return _buildLoadingState();
          } else if (provider.outfitState == AnalysisState.error) {
            return _buildErrorState(context, provider.errorMessage);
          } else if (provider.outfits.isNotEmpty) {
            return _buildOutfitsState(provider);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated sparkles
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Opacity(
                opacity: (1 - (value * 2 - 1).abs()),
                child: Transform.scale(
                  scale: 0.8 + value * 0.4,
                  child: child,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                shape: BoxShape.circle,
                boxShadow: AppTheme.glowShadow,
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppTheme.primaryBlack,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            'Creating your perfect outfits...',
            style: TextStyle(
              color: AppTheme.pureWhite,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Our AI stylist is working on it ✨',
            style: TextStyle(
              color: AppTheme.softGray,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 48),
          const ShimmerLoading(height: 200),
          const SizedBox(height: 16),
          const ShimmerLoading(height: 200),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
              'Could not generate outfits',
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
            ElevatedButton.icon(
              onPressed: () {
                context.read<ClothingProvider>().generateOutfits();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutfitsState(ClothingProvider provider) {
    final item = provider.currentItem;
    
    return CustomScrollView(
      slivers: [
        // Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item != null) ...[
                  Text(
                    'Outfits for your ${item.displayName}',
                    style: const TextStyle(
                      color: AppTheme.pureWhite,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${provider.outfits.length} outfit suggestions created by AI',
                    style: const TextStyle(
                      color: AppTheme.softGray,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        
        // Outfits list
        SliverPadding(
          padding: const EdgeInsets.all(24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final outfit = provider.outfits[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: OutfitCard(
                    outfit: outfit,
                    index: index + 1,
                  ),
                );
              },
              childCount: provider.outfits.length,
            ),
          ),
        ),
        
        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 48),
        ),
      ],
    );
  }
}
