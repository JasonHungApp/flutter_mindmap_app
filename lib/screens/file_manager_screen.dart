import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/mind_map_provider.dart';
import 'mind_map_screen.dart';

class FileManagerScreen extends StatefulWidget {
  const FileManagerScreen({super.key});

  @override
  State<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends State<FileManagerScreen> {
  late Future<List<String>> _mindMapsFuture;

  @override
  void initState() {
    super.initState();
    _loadMindMaps();
  }

  void _loadMindMaps() {
    _mindMapsFuture = context.read<MindMapProvider>().getSavedMindMaps();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的心智圖'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const MindMapScreen(),
                ),
              ).then((_) => _loadMindMaps());
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMindMaps,
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: _mindMapsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '還沒有任何心智圖',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const MindMapScreen(),
                        ),
                      ).then((_) => _loadMindMaps());
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('建立新的心智圖'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final filePath = snapshot.data![index];
              final fileName = filePath.split('/').last;
              final file = File(filePath);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.bubble_chart),
                  title: Text(fileName),
                  subtitle: FutureBuilder<String>(
                    future: file.lastModified().then(
                          (date) => '最後修改：${date.toString().split('.')[0]}',
                        ),
                    builder: (context, snapshot) {
                      return Text(snapshot.data ?? '');
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('確認刪除'),
                          content: const Text('確定要刪除這個心智圖嗎？'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('取消'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('刪除'),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await context
                            .read<MindMapProvider>()
                            .deleteSavedMindMap(filePath);
                        _loadMindMaps();
                      }
                    },
                  ),
                  onTap: () async {
                    try {
                      final content = await file.readAsString();
                      if (mounted) {
                        await context.read<MindMapProvider>().loadFromJson(content);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const MindMapScreen(),
                          ),
                        ).then((_) => _loadMindMaps());
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('載入心智圖時發生錯誤: $e')),
                        );
                      }
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
