import 'package:flutter/material.dart';
import 'core/design_system.dart';
import 'services/storage_service.dart';
import 'services/ad_service.dart';
import 'services/notification_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = StorageService();
  await storage.init();

  // Initialize these to ensure they are ready before the first screen loads
  await AdService().init();
  NotificationService().init();
  
  runApp(const NumbersApp());
}

class NumbersApp extends StatelessWidget {
  const NumbersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numbers',
      debugShowCheckedModeBanner: false,
      theme: NumbersTheme.lightTheme,
      themeMode: ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
