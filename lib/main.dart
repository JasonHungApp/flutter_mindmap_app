import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mind_map_provider.dart';
import 'widgets/mind_map_node_widget.dart';
import 'widgets/mind_map_connections.dart';
import 'widgets/saved_mind_maps_dialog.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'screens/mind_map_screen.dart';

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
        home: const MindMapScreen(),
      ),
    );
  }
}


