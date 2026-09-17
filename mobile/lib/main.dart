import 'package:flutter/material.dart';

import 'screens/main_navigation_screen.dart';

void main() {
  runApp(const DddFootballApp());
}

class DddFootballApp extends StatelessWidget {
  const DddFootballApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF35D07F);

    return MaterialApp(
      title: 'дДд Football',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0B111B),
        fontFamily: 'Arial',
      ),
      home: const MainNavigationScreen(),
    );
  }
}
