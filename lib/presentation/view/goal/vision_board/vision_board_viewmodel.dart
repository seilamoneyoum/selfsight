import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:selfsight/presentation/view/goal/vision_board/viewmodel/align_images_logic.dart';
import 'package:selfsight/presentation/view/goal/vision_board/viewmodel/background_logic.dart';
import 'package:selfsight/presentation/view/goal/vision_board/viewmodel/image_logic.dart';
import 'package:stacked/stacked.dart';
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';

class VisionBoardViewModel extends BaseViewModel {
  late final AlignImagesLogic alignImagesLogic;
  late final BackgroundLogic backgroundLogic;
  late final ImageLogic imageLogic;

  VisionBoardViewModel() {
    alignImagesLogic = AlignImagesLogic(viewModel: this);
    backgroundLogic = BackgroundLogic(viewModel: this);
    imageLogic = ImageLogic(viewModel: this);
  }

  List<String> _selectedIds = [];
  List<String> get selectedIds => _selectedIds;
  double? gestureStartScale;
  double? gestureStartRotation;

  //late VisionBoard visionBoard;

  List<VisionBoardItem> elements = [];
  VisionBoardItem? selectedItem;

  String selectedId = "-1";

  List<VisionBoardItem> get allElements => elements;

  void resetValues() {
    selectedId = "-1";
    selectedItem = null;
    notifyListeners();
  }

  void selectItem(String id) {
    selectedId = id;
    selectedItem = elements.where((item) => item.id == id).first;
    notifyListeners();
  }

  void pickMultipleImages() async {
    final List<XFile> selectedXImages = await ImagePicker().pickMultiImage(
      imageQuality: 20,
    );
    if (selectedXImages.isEmpty) return;

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String appDocPath = appDocDir.path;

    List<Future<VisionBoardItem>> futures = selectedXImages
        .map((xfile) => convertToVisionBoardItem(xfile, appDocPath))
        .toList();

    List<VisionBoardItem> newItems = await Future.wait(futures);
    elements.addAll(newItems);
    notifyListeners();
  }

  Future<VisionBoardItem> convertToVisionBoardItem(
    XFile xFile,
    String persistentDirectoryPath,
  ) async {
    final String uniqueFileName =
        '${DateTime.now().microsecondsSinceEpoch}_${xFile.name}';

    final File persistentFile = File(
      '$persistentDirectoryPath/$uniqueFileName',
    );

    try {
      final bytes = await xFile.readAsBytes();
      await persistentFile.writeAsBytes(bytes);
    } catch (e) {
      await File(xFile.path).copy(persistentFile.path);
    }

    return VisionBoardItem(
      position: Offset(100, 100),
      size: await getScaledWidth(persistentFile),
      imagePath: persistentFile.path,
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
}
