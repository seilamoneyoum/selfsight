import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';

class AlignImagesLogic {
  VisionBoardViewModel viewModel;
  bool _isAlignMode = false;
  bool get isAlignMode => _isAlignMode;
  String? axisSelection;
  String? positionSelection;
  List<String> _selectedIds = [];
  List<String> get selectedIds => _selectedIds;

  AlignImagesLogic({required this.viewModel});

  void setAlignImagesMode(bool alignMode) {
    _isAlignMode = alignMode;
    viewModel.notifyListeners();
  }

  void alignImages({required String axis, required String position}) {
    // À modifier [...]
    viewModel.notifyListeners();
  }

  void enterAlignMode() {
    _isAlignMode = true;
    _selectedIds = [];
    axisSelection = null;
    positionSelection = null;
    viewModel.notifyListeners();
  }

  // Quitter le mode alignement
  void exitAlignMode() {
    _isAlignMode = false;
    _selectedIds = [];
    axisSelection = null;
    positionSelection = null;
    viewModel.notifyListeners();
  }

  // Mettre à jour l'axe
  void setAxis(String axis) {
    axisSelection = axis;
    positionSelection = null;
    viewModel.notifyListeners();
  }

  // Mettre à jour la position
  void setPosition(String position) {
    positionSelection = position;
    viewModel.notifyListeners();
  }

  // Appliquer l'alignement
  void applyAlignment() {
    if (axisSelection != null && positionSelection != null) {
      alignImages(axis: axisSelection!, position: positionSelection!);
      exitAlignMode();
    }
  }
}
