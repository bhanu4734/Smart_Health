import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'app_router.dart';

class SmartHealthApp extends StatelessWidget {
  const SmartHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PHC.Dispensing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.welcome,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
