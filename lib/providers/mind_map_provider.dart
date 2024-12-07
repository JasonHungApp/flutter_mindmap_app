import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';
import '../models/mind_map_node.dart';

class MindMapProvider with ChangeNotifier {
  List<MindMapNode> _nodes = [];
  MindMapNode? _selectedNode;
  final _uuid = const Uuid();
  String? _connectionStartNodeId;

  // 添加画布范围常量
  static const double canvasWidth = 4000;
  static const double canvasHeight = 4000;
  static const double nodePadding = 20; // 节点与边界的最小距离

  List<MindMapNode> get nodes => _nodes;
  MindMapNode? get selectedNode => _selectedNode;
  String? get connectionStartNodeId => _connectionStartNodeId;

  // 确保坐标在画布范围内
  (double, double) _constrainPosition(double x, double y) {
    return (
      x.clamp(nodePadding, canvasWidth - nodePadding),
      y.clamp(nodePadding, canvasHeight - nodePadding)
    );
  }

  // 計算子節點的放射狀位置
  (double, double) _calculateRadialPosition(MindMapNode parentNode) {
    // 獲取父節點的所有子節點數量（包括即將添加的新節點）
    final childCount = parentNode.childrenIds.length + 1;
    
    // 設置放射狀佈局的參數
    const fixedAngleStep = 45.0; // 固定每個節點之間的角度差為45度
    const baseRadius = 150.0; // 第一圈的基礎半徑
    const startAngle = -60.0; // 開始角度（如果是 -90 度是正上方）
    
    // 計算當前節點在第幾圈和該圈中的位置
    final circleIndex = (childCount - 1) ~/ 8; // 第幾圈（0為第一圈）
    final positionInCircle = (childCount - 1) % 8; // 在當前圈的位置
    
    // 計算實際半徑（每圈增加100單位）
    final radius = baseRadius + (circleIndex * 100.0);
    
    // 計算角度（每個位置45度）
    final currentAngle = (startAngle + (fixedAngleStep * positionInCircle)) * (pi / 180.0);
    
    // 使用三角函數計算新位置
    final offsetX = radius * cos(currentAngle);
    final offsetY = radius * sin(currentAngle);
    
    // 相對於父節點的中心位置
    final parentCenterX = parentNode.x + 50; // 假設節點寬度為100
    final parentCenterY = parentNode.y + 20; // 假設節點高度為40
    
    return (
      parentCenterX + offsetX,
      parentCenterY + offsetY
    );
  }

  void addNode(String text, double x, double y, {String? parentId}) {
    final nodeId = _uuid.v4();
    double constrainedX;
    double constrainedY;

    if (parentId != null) {
      // 如果有父節點，使用放射狀佈局
      final parentNode = _nodes.firstWhere((node) => node.id == parentId);
      final (radialX, radialY) = _calculateRadialPosition(parentNode);
      final (constX, constY) = _constrainPosition(radialX, radialY);
      constrainedX = constX;
      constrainedY = constY;
    } else {
      // 如果是根節點，使用傳入的位置
      final (constX, constY) = _constrainPosition(x, y);
      constrainedX = constX;
      constrainedY = constY;
    }
    
    final node = MindMapNode(
      id: nodeId,
      text: text,
      x: constrainedX,
      y: constrainedY,
    );
    _nodes.add(node);
    
    if (parentId != null) {
      addConnection(parentId, nodeId);
    }
    
    selectNode(nodeId);
    
    notifyListeners();
  }

  void updateNodePosition(String id, double x, double y) {
    final nodeIndex = _nodes.indexWhere((node) => node.id == id);
    if (nodeIndex != -1) {
      final (constrainedX, constrainedY) = _constrainPosition(x, y);
      _nodes[nodeIndex] = _nodes[nodeIndex].copyWith(
        x: constrainedX,
        y: constrainedY
      );
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
    // First remove all connections to this node
    for (var node in _nodes) {
      if (node.childrenIds.contains(id)) {
        final updatedNode = node.copyWith(
          childrenIds: List<String>.from(node.childrenIds)..remove(id),
        );
        final index = _nodes.indexOf(node);
        _nodes[index] = updatedNode;
      }
    }

    // Then remove the node itself
    _nodes.removeWhere((node) => node.id == id);

    // If this was the selected node, clear selection
    if (_selectedNode?.id == id) {
      _selectedNode = null;
    }

    // If this was the connection start node, cancel connection
    if (_connectionStartNodeId == id) {
      _connectionStartNodeId = null;
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

  Future<void> loadFromJson(String jsonContent) async {
    try {
      final data = jsonDecode(jsonContent) as Map<String, dynamic>;
      _nodes = (data['nodes'] as List)
          .map((node) => MindMapNode.fromJson(node as Map<String, dynamic>))
          .toList();
      _selectedNode = null;
      _connectionStartNodeId = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error parsing mind map: $e');
      rethrow;
    }
  }

  Future<void> loadMindMap() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final content = await file.readAsString();
        await loadFromJson(content);
      }
    } catch (e) {
      debugPrint('Error loading mind map: $e');
      rethrow;
    }
  }

  Future<void> saveMindMap() async {
    try {
      // Get the application documents directory
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'mindmap_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      // Prepare the data
      final data = {
        'nodes': _nodes.map((node) => node.toJson()).toList(),
      };

      // Write to file
      await file.writeAsString(jsonEncode(data));

      debugPrint('Mind map saved to: ${file.path}');
    } catch (e) {
      debugPrint('Error saving mind map: $e');
      rethrow;
    }
  }

  Future<List<String>> getSavedMindMaps() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory
          .listSync()
          .where((file) => file.path.endsWith('.json'))
          .map((file) => file.path)
          .toList();
      return files;
    } catch (e) {
      debugPrint('Error getting saved mind maps: $e');
      return [];
    }
  }

  Future<void> deleteSavedMindMap(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('Mind map deleted: $filePath');
      }
    } catch (e) {
      debugPrint('Error deleting mind map: $e');
      rethrow;
    }
  }

  Future<void> shareMindMap() async {
    try {
      // Prepare the data
      final data = {
        'nodes': _nodes.map((node) => node.toJson()).toList(),
      };

      // Convert to JSON string
      final jsonString = jsonEncode(data);

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/mindmap_$timestamp.json';
      
      // Write to temporary file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: '分享心智圖',
        text: '請使用心智圖 App 開啟此檔案',
      );

      // Clean up temporary file after sharing
      await file.delete();
    } catch (e) {
      debugPrint('Error sharing mind map: $e');
      rethrow;
    }
  }

  void clearMindMap() {
    _nodes.clear();
    _selectedNode = null;
    _connectionStartNodeId = null;
    notifyListeners();
  }
}
