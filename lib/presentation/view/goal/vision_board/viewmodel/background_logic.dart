import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';

class BackgroundLogic {
  VisionBoardViewModel viewModel;
  bool isImageBackgroundSelected = false;
  Color _backgroundColor = Colors.white;
  File? _backgroundImage;
  BackgroundLogic({required this.viewModel});

  Color get backgroundColor => _backgroundColor;
  File? get backgroundImage => _backgroundImage;

  set backgroundColor(Color newColor) {
    isImageBackgroundSelected = false;
    _backgroundColor = newColor;
    viewModel.notifyListeners();
  }

  set backgroundImage(File? newFile) {
    isImageBackgroundSelected = true;
    _backgroundImage = newFile;
    viewModel.notifyListeners();
  }

  void pickBackgroundImage() async {
    final XFile? selectedXFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 20,
    );

    if (selectedXFile == null) return;

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final String uniqueFileName =
        'background_${DateTime.now().microsecondsSinceEpoch}_${selectedXFile.name}';
    final File persistentFile = File('${appDocDir.path}/$uniqueFileName');

    try {
      final bytes = await selectedXFile.readAsBytes();
      await persistentFile.writeAsBytes(bytes);
    } catch (e) {
      await File(selectedXFile.path).copy(persistentFile.path);
    }

    backgroundImage = persistentFile;

    viewModel.notifyListeners();
  }
}
