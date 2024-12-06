import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/mind_map_provider.dart';

class SavedMindMapsDialog extends StatelessWidget {
  const SavedMindMapsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '已儲存的心智圖',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<String>>(
              future: context.read<MindMapProvider>().getSavedMindMaps(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('沒有已儲存的心智圖');
                }

                return SizedBox(
                  width: 400,
                  height: 300,
                  child: ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final filePath = snapshot.data![index];
                      final fileName = filePath.split('/').last;
                      return Row(
                        children: [
                          Expanded(
                            child: ListTile(
                              title: Text(fileName),
                              onTap: () async {
                                Navigator.of(context).pop();
                                try {
                                  final file = File(filePath);
                                  final content = await file.readAsString();
                                  await context.read<MindMapProvider>().loadFromJson(content);
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
                              },
                            ),
                          ),
                          IconButton(
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
                                await context.read<MindMapProvider>().deleteSavedMindMap(filePath);
                                if (context.mounted) {
                                  // Refresh the dialog
                                  Navigator.pop(context);
                                  showDialog(
                                    context: context,
                                    builder: (context) => const SavedMindMapsDialog(),
                                  );
                                }
                              }
                            },
                          ),
                          const SizedBox(width: 8), // Add some padding on the right
                        ],
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('關閉'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
