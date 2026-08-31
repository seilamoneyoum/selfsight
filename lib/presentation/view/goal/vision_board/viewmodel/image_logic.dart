import 'dart:io';

import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';

class ImageLogic {
  VisionBoardViewModel viewModel;
  int _pointerCount = 0;
  bool get isMultiTouch => _pointerCount >= 2;

  ImageLogic({required this.viewModel});

  void incrementPointerCount() {
    _pointerCount++;
    viewModel.notifyListeners();
  }

  void decrementPointerCount() {
    if (_pointerCount > 0) _pointerCount--;
    viewModel.notifyListeners();
  }

  void removeItem(String id) {
    final itemToRemove = viewModel.elements.firstWhere((item) => item.id == id);

    try {
      final file = File(itemToRemove.imagePath);
      if (file.existsSync()) {
        file.deleteSync();
      }
    } finally {
      viewModel.elements.removeWhere((item) => item.id == id);
      viewModel.selectedId = "-1";
      viewModel.selectedItem = null;
      viewModel.notifyListeners();
    }
  }

  void resetRotation() {
    viewModel.selectedItem?.rotation = 0;
    viewModel.notifyListeners();
  }
}
