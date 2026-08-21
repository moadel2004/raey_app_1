import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class RaeyApp extends StatelessWidget {
  const RaeyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'راعى',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
