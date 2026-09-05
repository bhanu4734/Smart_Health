import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

enum AppButtonVariant { primary, secondary, outline, danger, compact }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.width,
    this.height = 42,
  });

  @override
  Widget build(BuildContext context) {
    if (variant == AppButtonVariant.compact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          hoverColor: AppColors.purpleLight.withValues(alpha: 0.5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.borderSubtle, width: 1),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
        ),
      );
    }

    Color bgColor;
    Color fgColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        bgColor = AppColors.purpleAccent;
        fgColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        bgColor = AppColors.primaryBlue;
        fgColor = Colors.white;
        break;
      case AppButtonVariant.outline:
        bgColor = Colors.white;
        fgColor = AppColors.textPrimary;
        borderSide = const BorderSide(color: AppColors.borderSubtle, width: 1);
        break;
      case AppButtonVariant.danger:
        bgColor = AppColors.redDark;
        fgColor = Colors.white;
        break;
      default:
        bgColor = AppColors.purpleAccent;
        fgColor = Colors.white;
    }

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          elevation: 0,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 16),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.2,
                      color: fgColor,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
