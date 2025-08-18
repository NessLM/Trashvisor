import 'package:flutter/material.dart';
import 'package:trashvisor/pages/onboarding/onboarding_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Created by Raihan Adi
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trashvisor App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const OnBoardingPage(),
    );
  }
}