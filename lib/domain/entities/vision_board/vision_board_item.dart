import 'dart:ui';

class VisionBoardItem {
  final String id;
  final String imagePath;
  Offset position;
  Size size;
  double rotation;
  double scale;
  final String createAt;

  VisionBoardItem({
    required this.id,
    required this.position,
    required this.size,
    required this.imagePath,
    required this.rotation,
    required this.scale,
    required this.createAt,
  });
}
