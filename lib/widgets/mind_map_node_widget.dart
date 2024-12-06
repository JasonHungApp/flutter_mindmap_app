import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/mind_map_node.dart';
import '../providers/mind_map_provider.dart';
import 'dart:math';

class MindMapNodeWidget extends StatefulWidget {
  final MindMapNode node;
  final bool isSelected;
  final bool isConnectionStart;
  final VoidCallback onTap;
  final Function(Offset)? onDragEnd;
  final Function(String)? onTextChanged;

  const MindMapNodeWidget({
    super.key,
    required this.node,
    required this.isSelected,
    this.isConnectionStart = false,
    required this.onTap,
    this.onDragEnd,
    this.onTextChanged,
  });

  @override
  State<MindMapNodeWidget> createState() => _MindMapNodeWidgetState();
}

class _MindMapNodeWidgetState extends State<MindMapNodeWidget> {
  bool _isEditing = false;
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.node.text);
  }

  @override
  void didUpdateWidget(MindMapNodeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node.text != widget.node.text) {
      _textController.text = widget.node.text;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() {
      _isEditing = true;
      // Select all text when starting to edit
      _textController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _textController.text.length,
      );
    });
  }

  void _finishEditing() {
    if (!_isEditing) return;
    
    setState(() {
      _isEditing = false;
      final newText = _textController.text.trim();
      if (newText.isNotEmpty && widget.onTextChanged != null) {
        widget.onTextChanged!(newText);
      } else {
        // If text is empty, revert to original text
        _textController.text = widget.node.text;
      }
    });
  }

  void _showContextMenu(BuildContext context, TapDownDetails details) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        details.globalPosition,
        details.globalPosition,
      ),
      Offset.zero & overlay.size,
    );

    showMenu(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          onTap: _startEditing,
          child: Row(
            children: const [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.link, size: 20),
              SizedBox(width: 8),
              Text('Start Connection'),
            ],
          ),
          onTap: () {
            widget.onTap();
                    },
        ),
        PopupMenuItem(
          child: const Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
          onTap: () {
            final provider = context.read<MindMapProvider>();
            provider.deleteNode(widget.node.id);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.node.x,
      top: widget.node.y,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: _startEditing,
        onSecondaryTapDown: (details) => _showContextMenu(context, details),
        onPanEnd: (details) {
          if (widget.onDragEnd != null) {
            widget.onDragEnd!(Offset(widget.node.x, widget.node.y));
          }
        },
        onPanUpdate: (details) {
          if (widget.onDragEnd != null) {
            widget.onDragEnd!(Offset(
              widget.node.x + details.delta.dx,
              widget.node.y + details.delta.dy,
            ));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(8.0),
          constraints: const BoxConstraints(
            minWidth: 100,
            minHeight: 40,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: widget.isConnectionStart 
                  ? Colors.green 
                  : widget.isSelected 
                      ? Colors.blue 
                      : Colors.grey,
              width: (widget.isSelected || widget.isConnectionStart) ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: _isEditing
              ? SizedBox(
                  width: max(100, _textController.text.length * 8.0), 
                  child: KeyboardListener(
                    focusNode: FocusNode(),
                    onKeyEvent: (event) {
                      if (event.logicalKey == LogicalKeyboardKey.escape) {
                        // Cancel editing on Escape
                        setState(() {
                          _isEditing = false;
                          _textController.text = widget.node.text;
                        });
                      }
                    },
                    child: TextField(
                      controller: _textController,
                      autofocus: true,
                      onSubmitted: (_) => _finishEditing(),
                      onEditingComplete: _finishEditing,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                )
              : Text(
                  widget.node.text,
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
        ),
      ),
    );
  }
}
