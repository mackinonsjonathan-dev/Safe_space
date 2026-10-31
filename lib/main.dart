import 'package:flutter/material.dart';

void main() {
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF004D40)),
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF004D40),
          title: const Text('Safe Space 🇰🇪', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: const Center(
          child: Text('Safe Space Mobile App Online!'),
        ),
      ),
    );
  }
}
