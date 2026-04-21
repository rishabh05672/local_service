import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';

// ─── Primary Button ───────────────────────────────────────────────────────────

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = AppSpacing.buttonHeight,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final AppButtonVariant variant;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.forward();
    }
  }

  void _onTapUp(_) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : widget.icon != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: AppSpacing.iconMd),
                  const SizedBox(width: AppSpacing.sm),
                  Text(widget.label),
                ],
              )
            : Text(widget.label);

    final style = switch (widget.variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: Size(widget.width ?? double.infinity, widget.height),
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          minimumSize: Size(widget.width ?? double.infinity, widget.height),
        ),
      AppButtonVariant.outlined => ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.primary,
          minimumSize: Size(widget.width ?? double.infinity, widget.height),
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          elevation: 0,
        ),
      AppButtonVariant.danger => ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          minimumSize: Size(widget.width ?? double.infinity, widget.height),
        ),
      AppButtonVariant.ghost => ElevatedButton.styleFrom(
          backgroundColor: AppColors.primarySurface,
          foregroundColor: AppColors.primary,
          minimumSize: Size(widget.width ?? double.infinity, widget.height),
          elevation: 0,
        ),
    };

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: ElevatedButton(
            onPressed: widget.isLoading ? null : () {
              HapticFeedback.lightImpact();
              widget.onPressed?.call();
            },
            style: style,
            child: child,
          ),
        ),
      ),
    );
  }
}

enum AppButtonVariant { primary, secondary, outlined, danger, ghost }

// ─── Gradient Button ──────────────────────────────────────────────────────────

class GradientButton extends StatefulWidget {
  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.gradient = AppColors.primaryGradient,
    this.icon,
    this.height = AppSpacing.buttonHeight,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Gradient gradient;
  final IconData? icon;
  final double height;

  @override
  State<GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<GradientButton> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.forward();
    }
  }

  void _onTapUp(_) {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.reverse();
    }
  }

  void _onTapCancel() {
    if (widget.onPressed != null && !widget.isLoading) {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.isLoading || widget.onPressed == null ? null : () {
          HapticFeedback.lightImpact();
          widget.onPressed?.call();
        },
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: AppRadius.button,
            boxShadow: AppShadows.fab,
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(widget.icon, color: Colors.white, size: AppSpacing.iconMd),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                      Text(
                        widget.label,
                        style: AppTypography.button(color: Colors.white),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ─── Icon Button ──────────────────────────────────────────────────────────────

class AppIconButton extends StatefulWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.iconSize = AppSpacing.iconLg,
    this.color,
    this.backgroundColor,
    this.bordered = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? backgroundColor;
  final bool bordered;

  @override
  State<AppIconButton> createState() => _AppIconButtonState();
}

class _AppIconButtonState extends State<AppIconButton> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.90).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onPressed != null) _animController.forward();
  }

  void _onTapUp(_) {
    if (widget.onPressed != null) _animController.reverse();
  }

  void _onTapCancel() {
    if (widget.onPressed != null) _animController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ??
        ((Theme.of(context).brightness == Brightness.dark) ? AppColors.darkSurface2 : AppColors.grey100);
    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onPressed == null ? null : () {
          HapticFeedback.lightImpact();
          widget.onPressed?.call();
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: widget.bordered
                ? Border.all(
                    color: (Theme.of(context).brightness == Brightness.dark) ? AppColors.darkBorder : AppColors.lightBorder,
                  )
                : null,
          ),
          child: Icon(
            widget.icon,
            size: widget.iconSize,
            color: widget.color ?? ((Theme.of(context).brightness == Brightness.dark) ? Colors.white : AppColors.grey700),
          ),
        ),
      ),
    );
  }
}
