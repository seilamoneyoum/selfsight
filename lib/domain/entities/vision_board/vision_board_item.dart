import 'dart:ui';

class VisionBoardItem {
  final String id;
  final String imagePath;
  final Offset position;
  final Size size;
  final double rotation;
  final double scale;
  final String createAt;

  const VisionBoardItem({
    required this.id,
    required this.position,
    required this.size,
    required this.imagePath,
    required this.rotation,
    required this.scale,
    required this.createAt,
  });
}
