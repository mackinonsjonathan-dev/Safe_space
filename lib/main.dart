import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SafeSpaceApp());
}

class SafeSpaceApp extends StatelessWidget {
  const SafeSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Safe Space Kenya',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF004D40),
          title: const Text('Safe Space 🇰🇪', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(
          child: Text('Safe Space Mobile App Online!'),
        ),
      ),
    );
  }
}
