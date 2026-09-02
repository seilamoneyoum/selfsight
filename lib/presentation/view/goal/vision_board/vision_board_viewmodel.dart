import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/presentation/view/goal/vision_board/viewmodel/align_images_logic.dart';
import 'package:selfsight/presentation/view/goal/vision_board/viewmodel/background_logic.dart';
import 'package:selfsight/presentation/view/goal/vision_board/viewmodel/image_logic.dart';
import 'package:selfsight/services/vision_board_service.dart';
import 'package:stacked/stacked.dart';
import 'package:image/image.dart' as image;
import 'package:path_provider/path_provider.dart';

class VisionBoardViewModel extends BaseViewModel {
  final String? goalId;
  final VisionBoardService _visionBoardService = locator<VisionBoardService>();
  late final AlignImagesLogic alignImagesLogic;
  late final BackgroundLogic backgroundLogic;
  late final ImageLogic imageLogic;

  VisionBoardViewModel({this.goalId}) {
    alignImagesLogic = AlignImagesLogic(viewModel: this);
    backgroundLogic = BackgroundLogic(viewModel: this);
    imageLogic = ImageLogic(viewModel: this);
  }

  double? gestureStartScale;
  double? gestureStartRotation;

  List<VisionBoardItem> elements = [];
  VisionBoardItem? selectedItem;

  String selectedId = "-1";

  List<VisionBoardItem> get allElements => elements;

  /// Charger le vision board existant lié à ce goal, s'il y en a un.
  /// Si le goal n'a pas encore été sauvegardé, il n'y a rien à charger.
  Future<void> loadVisionBoard() async {
    if (goalId == null) return;

    setBusy(true);
    final board = await _visionBoardService.getVisionBoardByGoalId(goalId!);
    if (board != null) {
      elements = board.items;

      if (board.backgroundImagePath != null) {
        backgroundLogic.backgroundImage = File(board.backgroundImagePath!);
      } else if (board.backgroundColorValue != null) {
        backgroundLogic.backgroundColor =
            VisionBoard.intToColor(board.backgroundColorValue)!;
      }
    }
    setBusy(false);
    notifyListeners();
  }

  /// Sauvegarder l'état actuel du board. Ne fait rien si le goal n'a pas
  /// encore été créé (pas de goalId).
  Future<void> saveVisionBoard() async {
    if (goalId == null) return;

    final board = VisionBoard(
      goalId: goalId!,
      items: elements,
      backgroundColorValue: backgroundLogic.isImageBackgroundSelected
          ? null
          : VisionBoard.colorToInt(backgroundLogic.backgroundColor),
      backgroundImagePath: backgroundLogic.isImageBackgroundSelected
          ? backgroundLogic.backgroundImage?.path
          : null,
    );

    await _visionBoardService.saveVisionBoard(board);
  }

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

// Déplace l'image sélectionnée d'un niveau vers l'avant
  void bringForward(String id) {
    int index = elements.indexWhere((item) => item.id == id);
// Impossible d'avancer si l'on se trouve déjà tout en haut
    if (index == -1 || index == elements.length - 1) return;

    final item = elements.removeAt(index);
    elements.insert(index + 1, item);
    notifyListeners();
  }

  /// Déplace l'image sélectionnée d'un niveau vers l'arrière
  void sendBackward(String id) {
    int index = elements.indexWhere((item) => item.id == id);
// Impossible de reculer si l'on se trouve déjà tout en bas
    if (index == -1 || index == 0) return;

    final item = elements.removeAt(index);
    elements.insert(index - 1, item);
    notifyListeners();
  }
}
