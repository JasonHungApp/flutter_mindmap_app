import 'package:flutter/material.dart';
import '../models/mind_map_node.dart';

class MindMapNodeWidget extends StatelessWidget {
  final MindMapNode node;
  final VoidCallback? onTap;
  final Function(Offset)? onDragEnd;
  final bool isSelected;

  const MindMapNodeWidget({
    Key? key,
    required this.node,
    this.onTap,
    this.onDragEnd,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: node.x,
      top: node.y,
      child: GestureDetector(
        onTap: onTap,
        onPanEnd: (details) {
          if (onDragEnd != null) {
            onDragEnd!(Offset(node.x, node.y));
          }
        },
        onPanUpdate: (details) {
          if (onDragEnd != null) {
            onDragEnd!(Offset(
              node.x + details.delta.dx,
              node.y + details.delta.dy,
            ));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            node.text,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
