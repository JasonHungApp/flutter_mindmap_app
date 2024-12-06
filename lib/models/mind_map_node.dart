class MindMapNode {
  final String id;
  final String text;
  final double x;
  final double y;
  final List<String> childrenIds;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'x': x,
      'y': y,
      'childrenIds': childrenIds,
    };
  }

  factory MindMapNode.fromJson(Map<String, dynamic> json) {
    return MindMapNode(
      id: json['id'] as String,
      text: json['text'] as String,
      x: json['x'] as double,
      y: json['y'] as double,
      childrenIds: (json['childrenIds'] as List<dynamic>).cast<String>(),
    );
  }
}
