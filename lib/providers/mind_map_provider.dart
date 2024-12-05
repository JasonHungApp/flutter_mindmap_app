import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/mind_map_node.dart';

class MindMapProvider extends ChangeNotifier {
  final List<MindMapNode> _nodes = [];
  MindMapNode? _selectedNode;
  final _uuid = const Uuid();

  List<MindMapNode> get nodes => _nodes;
  MindMapNode? get selectedNode => _selectedNode;

  void addNode(String text, double x, double y) {
    final node = MindMapNode(
      id: _uuid.v4(),
      text: text,
      x: x,
      y: y,
    );
    _nodes.add(node);
    notifyListeners();
  }

  void updateNodePosition(String id, double x, double y) {
    final nodeIndex = _nodes.indexWhere((node) => node.id == id);
    if (nodeIndex != -1) {
      _nodes[nodeIndex] = _nodes[nodeIndex].copyWith(x: x, y: y);
      notifyListeners();
    }
  }

  void updateNodeText(String id, String text) {
    final nodeIndex = _nodes.indexWhere((node) => node.id == id);
    if (nodeIndex != -1) {
      _nodes[nodeIndex] = _nodes[nodeIndex].copyWith(text: text);
      notifyListeners();
    }
  }

  void selectNode(String? id) {
    _selectedNode = id != null 
        ? _nodes.firstWhere((node) => node.id == id)
        : null;
    notifyListeners();
  }

  void deleteNode(String id) {
    _nodes.removeWhere((node) => node.id == id);
    if (_selectedNode?.id == id) {
      _selectedNode = null;
    }
    notifyListeners();
  }
}
