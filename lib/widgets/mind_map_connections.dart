import 'package:flutter/material.dart';
import '../models/mind_map_node.dart';

class MindMapConnections extends StatelessWidget {
  final List<MindMapNode> nodes;
  
  const MindMapConnections({
    super.key,
    required this.nodes,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: ConnectionsPainter(nodes: nodes),
    );
  }
}

class ConnectionsPainter extends CustomPainter {
  final List<MindMapNode> nodes;
  final Paint _paint;

  ConnectionsPainter({required this.nodes}) 
    : _paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

  @override
  void paint(Canvas canvas, Size size) {
    for (final node in nodes) {
      _drawConnections(canvas, node);
    }
  }

  void _drawConnections(Canvas canvas, MindMapNode parentNode) {
    final startPoint = Offset(
      parentNode.x + 50, // Approximate half width of node
      parentNode.y + 20, // Approximate half height of node
    );

    for (final childId in parentNode.childrenIds) {
      // Find the child node by ID
      final childNode = nodes.firstWhere(
        (node) => node.id == childId,
        orElse: () => parentNode, // Fallback to parent if child not found
      );

      final endPoint = Offset(
        childNode.x + 50, // Approximate half width of node
        childNode.y + 20, // Approximate half height of node
      );

      // Draw a line from parent to child
      canvas.drawLine(startPoint, endPoint, _paint);
    }
  }

  @override
  bool shouldRepaint(ConnectionsPainter oldDelegate) {
    return oldDelegate.nodes != nodes;
  }
}
