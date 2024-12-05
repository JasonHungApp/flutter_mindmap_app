import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/mind_map_node.dart';

class MindMapProvider extends ChangeNotifier {
  final List<MindMapNode> _nodes = [];
  MindMapNode? _selectedNode;
  final _uuid = const Uuid();
  String? _connectionStartNodeId;

  List<MindMapNode> get nodes => _nodes;
  MindMapNode? get selectedNode => _selectedNode;
  String? get connectionStartNodeId => _connectionStartNodeId;

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

  void addConnection(String parentId, String childId) {
    final parentIndex = _nodes.indexWhere((node) => node.id == parentId);
    
    if (parentIndex != -1 && !_nodes[parentIndex].childrenIds.contains(childId)) {
      final updatedParent = _nodes[parentIndex].copyWith(
        childrenIds: [..._nodes[parentIndex].childrenIds, childId],
      );
      _nodes[parentIndex] = updatedParent;
      notifyListeners();
    }
  }

  void removeConnection(String parentId, String childId) {
    final parentIndex = _nodes.indexWhere((node) => node.id == parentId);
    
    if (parentIndex != -1) {
      final updatedChildrenIds = List<String>.from(_nodes[parentIndex].childrenIds)
        ..remove(childId);
      
      final updatedParent = _nodes[parentIndex].copyWith(
        childrenIds: updatedChildrenIds,
      );
      _nodes[parentIndex] = updatedParent;
      notifyListeners();
    }
  }

  void startConnection(String nodeId) {
    _connectionStartNodeId = nodeId;
    notifyListeners();
  }

  void completeConnection(String endNodeId) {
    if (_connectionStartNodeId != null && _connectionStartNodeId != endNodeId) {
      addConnection(_connectionStartNodeId!, endNodeId);
    }
    _connectionStartNodeId = null;
    notifyListeners();
  }

  void cancelConnection() {
    _connectionStartNodeId = null;
    notifyListeners();
  }
}
