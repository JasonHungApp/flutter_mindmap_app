import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/mind_map_provider.dart';
import '../widgets/mind_map_node_widget.dart';
import '../widgets/mind_map_connections.dart';
import '../widgets/saved_mind_maps_dialog.dart';

class MindMapScreen extends StatefulWidget {
  const MindMapScreen({super.key});

  @override
  State<MindMapScreen> createState() => _MindMapScreenState();
}

class _MindMapScreenState extends State<MindMapScreen> {
  final TransformationController _transformationController = TransformationController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
                        const SnackBar(content: Text('心智圖儲存成功')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('儲存心智圖時發生錯誤: $e')),
                      );
                    }
                  }
                  break;
                case 'load':
                  try {
                    await provider.loadMindMap();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('心智圖載入成功')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('載入心智圖時發生錯誤: $e')),
                      );
                    }
                  }
                  break;
                case 'share':
                  try {
                    await provider.shareMindMap();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('分享心智圖時發生錯誤: $e')),
                      );
                    }
                  }
                  break;
                case 'files':
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => const SavedMindMapsDialog(),
                    );
                  }
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new',
                child: Text('新建心智圖'),
              ),
              const PopupMenuItem(
                value: 'save',
                child: Text('儲存心智圖'),
              ),
              const PopupMenuItem(
                value: 'load',
                child: Text('載入心智圖'),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Text('分享心智圖'),
              ),
              const PopupMenuItem(
                value: 'files',
                child: Text('管理檔案'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              final provider = context.read<MindMapProvider>();
              // 獲取當前視圖的變換矩陣
              final matrix = _transformationController.value;
              // 計算視圖中心點在畫布上的實際位置
              final viewportCenter = MatrixUtils.transformPoint(
                matrix, 
                Offset(
                  MediaQuery.of(context).size.width / 2,
                  MediaQuery.of(context).size.height / 2,
                ),
              );
              provider.addNode(
                'New Node',
                viewportCenter.dx,
                viewportCenter.dy,
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
          return LayoutBuilder(
            builder: (context, constraints) {
              return InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(100),
                minScale: 0.1,
                maxScale: 3.0,
                transformationController: _transformationController,
                constrained: false,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 4000,
                    minHeight: 4000,
                    maxWidth: 4000,
                    maxHeight: 4000,
                  ),
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                    child: Center(
                      child: Stack(
                        clipBehavior: Clip.none,
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
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
