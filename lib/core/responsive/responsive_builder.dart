import 'package:flutter/material.dart';
import 'breakpoints.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context)? tablet;
  final Widget Function(BuildContext context) desktop;

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > AppBreakpoints.tablet) {
          return desktop(context);
        } else if (constraints.maxWidth >= AppBreakpoints.mobile && tablet != null) {
          return tablet!(context);
        } else {
          return mobile(context);
        }
      },
    );
  }
}
