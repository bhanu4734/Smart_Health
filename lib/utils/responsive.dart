import 'package:flutter/material.dart';

enum DeviceScreenType {
  mobile,
  tablet,
  desktop,
}

class Responsive {
  static const double mobileMaxWidth = 600;
  static const double tabletMaxWidth = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMaxWidth;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileMaxWidth &&
      MediaQuery.of(context).size.width <= tabletMaxWidth;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width > tabletMaxWidth;

  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMaxWidth) {
      return DeviceScreenType.mobile;
    } else if (width <= tabletMaxWidth) {
      return DeviceScreenType.tablet;
    } else {
      return DeviceScreenType.desktop;
    }
  }

  static double contentWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileMaxWidth) {
      return width;
    } else if (width <= tabletMaxWidth) {
      return 720;
    } else {
      return 960;
    }
  }
}
