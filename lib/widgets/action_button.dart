import 'package:flutter/material.dart';
import '../app/theme.dart';

class ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const ActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(6),
        hoverColor: AppColors.purpleLight.withValues(alpha: 0.5),
        splashColor: AppColors.purpleLight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isPrimary ? AppColors.purpleLight : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isPrimary ? AppColors.purpleAccent : AppColors.borderSubtle,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPrimary ? AppColors.purpleAccent : AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
