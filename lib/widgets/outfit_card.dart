import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/outfit.dart';

class OutfitCard extends StatelessWidget {
  final Outfit outfit;
  final int index;

  const OutfitCard({
    super.key,
    required this.outfit,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.goldAccent.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.goldAccent.withOpacity(0.1),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge),
                topRight: Radius.circular(AppTheme.radiusLarge),
              ),
            ),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.goldGradient,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: AppTheme.primaryBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Title and style
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outfit.name,
                        style: const TextStyle(
                          color: AppTheme.pureWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(outfit.styleEmoji, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            outfit.style.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.goldAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppTheme.softGray,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              outfit.occasion,
                              style: const TextStyle(
                                color: AppTheme.softGray,
                                fontSize: 12,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Items list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: outfit.items.asMap().entries.map((entry) {
                final item = entry.value;
                final isLast = entry.key == outfit.items.length - 1;
                
                return Column(
                  children: [
                    _buildOutfitItem(item),
                    if (!isLast)
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        height: 20,
                        width: 1,
                        color: AppTheme.softGray.withOpacity(0.3),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
          
          // Tips
          if (outfit.tips.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBlack,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Styling Tip',
                            style: TextStyle(
                              color: AppTheme.goldAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            outfit.tips,
                            style: const TextStyle(
                              color: AppTheme.pureWhite,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildOutfitItem(OutfitItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlack,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                item.typeEmoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _capitalize(item.type),
                  style: const TextStyle(
                    color: AppTheme.softGray,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: const TextStyle(
                    color: AppTheme.pureWhite,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Color indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.secondaryBlack,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.color,
              style: const TextStyle(
                color: AppTheme.softGray,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
