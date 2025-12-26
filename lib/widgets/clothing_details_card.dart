import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/clothing_item.dart';

class ClothingDetailsCard extends StatelessWidget {
  final ClothingItem item;

  const ClothingDetailsCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.goldAccent.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (item.description.isNotEmpty) ...[
            Text(
              item.description,
              style: const TextStyle(
                color: AppTheme.pureWhite,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // Details grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildDetailChip('Style', item.style, Icons.style),
              _buildDetailChip('Pattern', item.pattern, Icons.texture),
              _buildDetailChip('Material', item.material, Icons.layers),
              _buildDetailChip('Season', item.season, Icons.wb_sunny_outlined),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Colors
          Row(
            children: [
              const Icon(
                Icons.palette_outlined,
                color: AppTheme.softGray,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Colors:',
                style: TextStyle(
                  color: AppTheme.softGray,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 8),
              ...item.colors.take(4).map((color) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryBlack,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    color,
                    style: const TextStyle(
                      color: AppTheme.pureWhite,
                      fontSize: 11,
                    ),
                  ),
                ),
              )),
            ],
          ),
          
          // Occasions
          if (item.occasions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.event_outlined,
                  color: AppTheme.softGray,
                  size: 16,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Best for:',
                  style: TextStyle(
                    color: AppTheme.softGray,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: item.occasions.map((occasion) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.goldGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        occasion,
                        style: const TextStyle(
                          color: AppTheme.primaryBlack,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ],
          
          // Brand
          if (item.brand != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.local_offer_outlined,
                  color: AppTheme.goldAccent,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  item.brand!,
                  style: const TextStyle(
                    color: AppTheme.goldAccent,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.secondaryBlack,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.softGray, size: 14),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.softGray,
                  fontSize: 10,
                ),
              ),
              Text(
                _capitalize(value),
                style: const TextStyle(
                  color: AppTheme.pureWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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
