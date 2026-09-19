import 'package:flutter/material.dart';
import '../../app/app_theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? leftAccentColor;
  final double leftAccentWidth;
  final Color? borderColor;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.margin,
    this.leftAccentColor,
    this.leftAccentWidth = 3.5,
    this.borderColor,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Container(
      padding: padding,
      color: backgroundColor,
      child: child,
    );

    if (leftAccentColor != null) {
      cardContent = IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: leftAccentWidth,
              decoration: BoxDecoration(
                color: leftAccentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.md),
                  bottomLeft: Radius.circular(AppRadius.md),
                ),
              ),
            ),
            Expanded(child: cardContent),
          ],
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: borderColor ?? AppColors.borderCard,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 2),
            blurRadius: 10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: cardContent,
    );
  }
}
