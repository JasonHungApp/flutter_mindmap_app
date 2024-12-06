import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mind_map_provider.dart';
import 'dart:io';
import 'screens/mind_map_screen.dart';
import 'screens/intro_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MindMapProvider(),
      child: MaterialApp(
        title: 'Mind Map App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: const IntroScreen(),
      ),
    );
  }
}
