import 'package:flutter/material.dart';
import 'core/design_system.dart';
import 'services/storage_service.dart';
import 'services/ad_service.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = StorageService();
  await storage.init();

  final adService = AdService();
  await adService.init();
  
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
      darkTheme: NumbersTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}
