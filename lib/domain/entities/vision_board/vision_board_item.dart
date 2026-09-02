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

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'positionX': position.dx,
        'positionY': position.dy,
        'width': size.width,
        'height': size.height,
        'rotation': rotation,
        'scale': scale,
        'createAt': createAt,
      };

  factory VisionBoardItem.fromJson(Map<String, dynamic> json) {
    return VisionBoardItem(
      id: json['id'],
      imagePath: json['imagePath'],
      position: Offset(json['positionX'], json['positionY']),
      size: Size(json['width'], json['height']),
      rotation: json['rotation'],
      scale: json['scale'],
      createAt: json['createAt'],
    );
  }
}
