import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:stacked/stacked.dart';

class VisionBoardViewModel extends BaseViewModel {
  late VisionBoard visionBoard;
  bool isImageBackgroundSelected = false;
  List<VisionBoardItem> elements = [];
  Color _backgroundColor = Colors.white;
  File? _backgroundImage;

  List<VisionBoardItem> get allElements => visionBoard.elements ?? [];
  Color get backgroundColor => _backgroundColor;
  File? get backgroundImage => _backgroundImage;

  set backgroundColor(Color newColor) {
    isImageBackgroundSelected = false;
    _backgroundColor = newColor;
    notifyListeners();
  }

  set backgroundImage(File? newFile) {
    isImageBackgroundSelected = true;
    _backgroundImage = newFile;
    notifyListeners();
  }

  void pickBackgroundImage() async {
    final XFile? selectedXFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );

    if (selectedXFile == null) return;

    backgroundImage = File(selectedXFile.path);

    notifyListeners();
  }

  void pickMultipleImages() async {
    final List<XFile> selectedXImages = await ImagePicker().pickMultiImage(
      imageQuality: 20,
    );

    if (selectedXImages.isEmpty) return;

    final List<File> selectedImages =
        selectedXImages.map((xfile) => File(xfile.path)).toList();

    elements +=
        selectedImages.map((file) => convertToVisionBoardItem(file)).toList();

    notifyListeners();
  }

  VisionBoardItem convertToVisionBoardItem(File imageFile) {
    return VisionBoardItem(
      position: Offset(100, 100),
      size: Size(100, 100),
      imagePath: imageFile.path,
      id: UniqueKey().toString(),
      rotation: 0,
      scale: 1,
      createAt: DateTime.now().toIso8601String(),
    );
  }

  void addImages() {}

  void selectElement() {}
  void addElement() {}
  void removeElement() {}

  void saveBoard() {}
  void quit() {}

  void updatePhotoPosition(String photoId, double x, double y) {}
  void updatePhotoRotation(String photoId, double rotation) {}
  void updatePhotoSize(String photoId, double width, double height) {}
  void bringToFront(String photoId) {}

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
