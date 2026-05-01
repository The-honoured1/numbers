import 'package:flutter/material.dart';
import 'core/design_system.dart';
import 'presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
