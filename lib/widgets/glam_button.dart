import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GlamButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool isPrimary;
  final bool isLoading;

  const GlamButton({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.isPrimary = true,
    this.isLoading = false,
  });

  @override
  State<GlamButton> createState() => _GlamButtonState();
}

class _GlamButtonState extends State<GlamButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : _onTapDown,
      onTapUp: widget.isLoading ? null : _onTapUp,
      onTapCancel: widget.isLoading ? null : _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.isPrimary ? AppTheme.goldGradient : null,
            color: widget.isPrimary ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: widget.isPrimary
                ? null
                : Border.all(color: AppTheme.goldAccent, width: 2),
            boxShadow: widget.isPrimary && !_isPressed
                ? [
                    BoxShadow(
                      color: AppTheme.goldAccent.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.isPrimary
                        ? AppTheme.primaryBlack
                        : AppTheme.goldAccent,
                  ),
                )
              else
                Icon(
                  widget.icon,
                  color: widget.isPrimary
                      ? AppTheme.primaryBlack
                      : AppTheme.goldAccent,
                  size: 20,
                ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isPrimary
                      ? AppTheme.primaryBlack
                      : AppTheme.goldAccent,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
