import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:stacked/stacked.dart';
import 'package:image/image.dart' as image;

class VisionBoardViewModel extends BaseViewModel {
  //late VisionBoard visionBoard;
  bool isImageBackgroundSelected = false;
  List<VisionBoardItem> elements = [];
  Color _backgroundColor = Colors.white;
  File? _backgroundImage;
  String selectedIndex = "-1";

  List<VisionBoardItem> get allElements => elements;
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

    // Convert each file to a VisionBoardItem asynchronously
    List<Future<VisionBoardItem>> futures = selectedXImages
        .map((xfile) => convertToVisionBoardItem(File(xfile.path)))
        .toList();

    List<VisionBoardItem> newItems = await Future.wait(futures);
    elements.addAll(newItems);
    notifyListeners();
  }

  Future<VisionBoardItem> convertToVisionBoardItem(File imageFile) async {
    return VisionBoardItem(
      position: Offset(100, 100),
      size: await getScaledWidth(imageFile),
      imagePath: imageFile.path,
      id: UniqueKey().toString(),
      rotation: 0,
      scale: 1,
      createAt: DateTime.now().toIso8601String(),
    );
  }

  Future<Size> getScaledWidth(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decodedImage = image.decodeImage(bytes);

    final originalWidth = decodedImage?.width ?? 100;
    final originalHeight = decodedImage?.height ?? 100;

    const double maxSize = 150.0;

    double scale = 1.0;
    if (originalWidth > maxSize || originalHeight > maxSize) {
      double scaleW = maxSize / originalWidth;
      double scaleH = maxSize / originalHeight;
      scale = scaleW < scaleH ? scaleW : scaleH;
    }

    final scaledWidth = originalWidth * scale;
    final scaledHeight = originalHeight * scale;

    return Size(scaledWidth, scaledHeight);
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
