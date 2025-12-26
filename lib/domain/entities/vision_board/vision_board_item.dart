import 'dart:ui';

class VisionBoardItem {
  final Offset position;
  final Size size;
  final String imageLink;
  final String id;
  final double rotation;
  final double scale;

  const VisionBoardItem({
    required this.position,
    required this.size,
    required this.imageLink,
    required this.id,
    required this.rotation,
    required this.scale,
  });
}
