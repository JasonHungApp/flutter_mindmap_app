import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mind_map_provider.dart';
import 'widgets/mind_map_node_widget.dart';

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

class MindMapScreen extends StatelessWidget {
  const MindMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final provider = context.read<MindMapProvider>();
              provider.addNode(
                'New Node',
                MediaQuery.of(context).size.width / 2,
                MediaQuery.of(context).size.height / 2,
              );
            },
          ),
        ],
      ),
      body: Consumer<MindMapProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              for (final node in provider.nodes)
                MindMapNodeWidget(
                  key: ValueKey(node.id),
                  node: node,
                  isSelected: node.id == provider.selectedNode?.id,
                  onTap: () => provider.selectNode(node.id),
                  onDragEnd: (offset) {
                    provider.updateNodePosition(node.id, offset.dx, offset.dy);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
