import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:local_service_app/shared/tokens/tokens.dart';
import 'shimmer_widgets.dart';

// ─── App Avatar ───────────────────────────────────────────────────────────────

class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AppSpacing.avatarMd,
    this.isOnline = false,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildAvatar(context),
        if (isOnline)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: size * 0.28,
              height: size * 0.28,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => ShimmerBox(
            width: size,
            height: size,
            radius: AppRadius.circle,
          ),
          errorWidget: (_, __, ___) => _buildInitials(context),
        ),
      );
    }
    return _buildInitials(context);
  }

  Widget _buildInitials(BuildContext context) {
    final initials = _getInitials();
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontFamily: AppTypography.fontFamily,
            fontSize: size * 0.38,
            fontWeight: AppTypography.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';
    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name![0].toUpperCase();
  }
}

// ─── Network Image with Shimmer ───────────────────────────────────────────────

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => ShimmerBox(
        width: width,
        height: height ?? 120,
        radius: borderRadius ?? AppRadius.r8,
      ),
      errorWidget: (_, __, ___) => Container(
        width: width,
        height: height,
        color: AppColors.grey200,
        child: const Icon(Icons.broken_image_rounded, color: AppColors.grey400),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}

// ─── App Input Field ──────────────────────────────────────────────────────────

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofillHints,
    this.textInputAction,
    this.focusNode,
    this.enabled = true,
    this.onFieldSubmitted,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Iterable<String>? autofillHints;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool enabled;
  final void Function(String)? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      onFieldSubmitted: onFieldSubmitted,
      readOnly: readOnly,
      maxLines: obscureText ? 1 : maxLines,
      minLines: minLines,
      maxLength: maxLength,
      autofillHints: autofillHints,
      textInputAction: textInputAction,
      focusNode: focusNode,
      enabled: enabled,
      style: AppTypography.bodyMedium(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : AppColors.grey900,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: AppSpacing.iconMd, color: AppColors.grey500)
            : null,
        suffixIcon: suffixIcon,
        counterText: '',
      ),
    );
  }
}
