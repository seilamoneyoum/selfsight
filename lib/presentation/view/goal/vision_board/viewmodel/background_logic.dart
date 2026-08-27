import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

    backgroundImage = File(selectedXFile.path);

    viewModel.notifyListeners();
  }
}
