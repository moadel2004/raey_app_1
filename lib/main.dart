import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/injection_container.dart';
import 'app/raey_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator(); // initialises SharedPreferences + DI graph

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const RaeyApp());
}
