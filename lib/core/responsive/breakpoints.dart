import 'package:flutter/material.dart';

class AppBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 1024.0;
  static const double desktop = 1440.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width <= tablet;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > tablet;

  static bool isLargeDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > desktop;
}
