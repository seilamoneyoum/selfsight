import 'dart:ui';
import 'package:selfsight/domain/entities/vision_board/vision_board.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:stacked/stacked.dart';

class VisionBoardViewModel extends BaseViewModel {
  late VisionBoard visionBoard;
  List<VisionBoardItem> elements = [];

  void addText(String text) {}

  void selectElement() {}
  void addElement() {}
  void removeElement() {}
  void saveBoard() {}
  void quit() {}

  void updatePhotoPosition(String photoId, double x, double y) {}

  void updatePhotoSize(String photoId, double width, double height) {}
  void bringToFront(String photoId) {} // Z-index management

  void undo() {}
  void redo() {}

  void changeBackground(String imageUrl) {}
  void changeBackgroundColor(Color color) {}

  void exportAsImage() {}
  void exportAsJson() {}
  void importFromJson(String jsonData) {}

  void clearSelection() {}
  void resetBoard() {}
  void toggleGrid(bool showGrid) {}
}
