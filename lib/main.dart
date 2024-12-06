import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/mind_map_provider.dart';
import 'widgets/mind_map_node_widget.dart';
import 'widgets/mind_map_connections.dart';
import 'dart:convert';
import 'dart:io';

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
          PopupMenuButton<String>(
            icon: const Icon(Icons.menu),
            onSelected: (value) async {
              final provider = context.read<MindMapProvider>();
              switch (value) {
                case 'new':
                  provider.clearMindMap();
                  break;
                case 'save':
                  try {
                    await provider.saveMindMap();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mind map saved successfully')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error saving mind map: $e')),
                      );
                    }
                  }
                  break;
                case 'load':
                  try {
                    await provider.loadMindMap();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mind map loaded successfully')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error loading mind map: $e')),
                      );
                    }
                  }
                  break;
                case 'files':
                  if (context.mounted) {
                    final files = await provider.getSavedMindMaps();
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Saved Mind Maps'),
                          content: SizedBox(
                            width: double.maxFinite,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: files.length,
                              itemBuilder: (context, index) {
                                final file = File(files[index]);
                                final fileName = file.path.split('/').last;
                                return ListTile(
                                  title: Text(fileName),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    try {
                                      final content = await file.readAsString();
                                      await provider.loadFromJson(content);
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Mind map loaded successfully')),
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error loading mind map: $e')),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      );
                    }
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.file_open),
                    SizedBox(width: 8),
                    Text('New Mind Map'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Save Mind Map'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'load',
                child: Row(
                  children: [
                    Icon(Icons.folder_open),
                    SizedBox(width: 8),
                    Text('Load Mind Map'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'files',
                child: Row(
                  children: [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text('Saved Mind Maps'),
                  ],
                ),
              ),
            ],
          ),
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
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () {
              final provider = context.read<MindMapProvider>();
              if (provider.selectedNode != null) {
                provider.startConnection(provider.selectedNode!.id);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              final provider = context.read<MindMapProvider>();
              if (provider.selectedNode != null) {
                provider.deleteNode(provider.selectedNode!.id);
              }
            },
          ),
        ],
      ),
      body: Consumer<MindMapProvider>(
        builder: (context, provider, child) {
          return Stack(
            children: [
              MindMapConnections(nodes: provider.nodes),
              for (final node in provider.nodes)
                MindMapNodeWidget(
                  key: ValueKey(node.id),
                  node: node,
                  isSelected: node.id == provider.selectedNode?.id,
                  isConnectionStart: node.id == provider.connectionStartNodeId,
                  onTap: () {
                    if (provider.connectionStartNodeId != null) {
                      provider.completeConnection(node.id);
                    } else {
                      provider.selectNode(node.id);
                    }
                  },
                  onDragEnd: (offset) {
                    provider.updateNodePosition(node.id, offset.dx, offset.dy);
                  },
                  onTextChanged: (text) {
                    provider.updateNodeText(node.id, text);
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
