import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../core/theme/app_theme.dart';

class ShimmerLoading extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = AppTheme.radiusMedium,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.cardBackground,
      highlightColor: AppTheme.secondaryBlack,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class ShimmerText extends StatelessWidget {
  final double width;
  final double height;

  const ShimmerText({
    super.key,
    this.width = 100,
    this.height = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppTheme.cardBackground,
      highlightColor: AppTheme.secondaryBlack,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
