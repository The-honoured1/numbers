import 'package:flutter/material.dart';
import 'core/design_system.dart';
import 'services/storage_service.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storage = StorageService();
  await storage.init();
  
  runApp(const NumeriaApp());
}

class NumeriaApp extends StatelessWidget {
  const NumeriaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numeria',
      debugShowCheckedModeBanner: false,
      theme: NumeriaTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
