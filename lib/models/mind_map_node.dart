class MindMapNode {
  String id;
  String text;
  double x;
  double y;
  List<MindMapNode> children;

  MindMapNode({
    required this.id,
    required this.text,
    required this.x,
    required this.y,
    List<MindMapNode>? children,
  }) : children = children ?? [];

  MindMapNode copyWith({
    String? id,
    String? text,
    double? x,
    double? y,
    List<MindMapNode>? children,
  }) {
    return MindMapNode(
      id: id ?? this.id,
      text: text ?? this.text,
      x: x ?? this.x,
      y: y ?? this.y,
      children: children ?? this.children,
    );
  }
}
