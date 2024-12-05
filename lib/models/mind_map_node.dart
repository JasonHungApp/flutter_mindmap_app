class MindMapNode {
  String id;
  String text;
  double x;
  double y;
  List<String> childrenIds;

  MindMapNode({
    required this.id,
    required this.text,
    required this.x,
    required this.y,
    List<String>? childrenIds,
  }) : childrenIds = childrenIds ?? [];

  MindMapNode copyWith({
    String? id,
    String? text,
    double? x,
    double? y,
    List<String>? childrenIds,
  }) {
    return MindMapNode(
      id: id ?? this.id,
      text: text ?? this.text,
      x: x ?? this.x,
      y: y ?? this.y,
      childrenIds: childrenIds ?? this.childrenIds,
    );
  }
}
