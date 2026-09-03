import 'dart:ui';
import 'vision_board_item.dart';

class VisionBoard {
  final String goalId;
  List<VisionBoardItem> items;
  int? backgroundColorValue;
  String? backgroundImagePath;
  String? snapshotPath;

  VisionBoard({
    required this.goalId,
    this.items = const [],
    this.backgroundColorValue,
    this.backgroundImagePath,
    this.snapshotPath,
  });

  factory VisionBoard.fromJson(Map<String, dynamic> json) {
    return VisionBoard(
      goalId: json['goalId'],
      items: (json['items'] as List?)
              ?.map((e) => VisionBoardItem.fromJson(e))
              .toList() ??
          [],
      backgroundColorValue: json['backgroundColorValue'],
      backgroundImagePath: json['backgroundImagePath'],
      snapshotPath: json['snapshotPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goalId': goalId,
      'items': items.map((e) => e.toJson()).toList(),
      'backgroundColorValue': backgroundColorValue,
      'backgroundImagePath': backgroundImagePath,
      'snapshotPath': snapshotPath,
    };
  }

  static int? colorToInt(Color? color) => color?.toARGB32();
  static Color? intToColor(int? value) => value != null ? Color(value) : null;
}
