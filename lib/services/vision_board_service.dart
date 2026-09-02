import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board.dart';

class VisionBoardService {
  static const String _visionBoardsKey = 'vision_boards_list';

  /// Sauvegarder l'image d'un item (photo ajoutée au board) comme fichier.
  Future<String?> saveImageFile(Uint8List imageBytes) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String fileName =
          'vision_board_item_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${appDocDir.path}/$fileName';

      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);
      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Effacer un fichier image (item retiré du board, ou board supprimé).
  Future<void> deleteImageFile(String? path) async {
    if (path == null) return;
    try {
      final File file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      // On ignore les erreurs.
    }
  }

  /// Sauvegarder le vision board d'un goal (nouveau ou existant).
  Future<void> saveVisionBoard(VisionBoard board) async {
    final preferences = await SharedPreferences.getInstance();
    List<VisionBoard> currentBoards = await getAllVisionBoards();

    currentBoards.removeWhere((b) => b.goalId == board.goalId);
    currentBoards.add(board);

    List<String> jsonList =
        currentBoards.map((b) => jsonEncode(b.toJson())).toList();

    await preferences.setStringList(_visionBoardsKey, jsonList);
  }

  // Charger tous les vision boards sauvegardés
  Future<List<VisionBoard>> getAllVisionBoards() async {
    final preferences = await SharedPreferences.getInstance();
    List<String>? jsonList = preferences.getStringList(_visionBoardsKey);

    if (jsonList == null || jsonList.isEmpty) return [];

    return jsonList.map((jsonString) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return VisionBoard.fromJson(jsonMap);
    }).toList();
  }

  /// Récupérer le vision board d'un goal donné, ou null s'il n'en a pas encore.
  Future<VisionBoard?> getVisionBoardByGoalId(String goalId) async {
    List<VisionBoard> allBoards = await getAllVisionBoards();
    try {
      return allBoards.firstWhere((b) => b.goalId == goalId);
    } catch (e) {
      return null;
    }
  }

  /// Effacer le vision board d'un goal (et les fichiers image associés).
  Future<void> deleteVisionBoardByGoalId(String goalId) async {
    final preferences = await SharedPreferences.getInstance();
    List<VisionBoard> currentBoards = await getAllVisionBoards();

    final boardToDelete =
        currentBoards.where((b) => b.goalId == goalId).firstOrNull;
    if (boardToDelete != null) {
      await deleteImageFile(boardToDelete.backgroundImagePath);
      for (final item in boardToDelete.items) {
        await deleteImageFile(item.imagePath);
      }
    }

    currentBoards.removeWhere((b) => b.goalId == goalId);

    List<String> jsonList =
        currentBoards.map((b) => jsonEncode(b.toJson())).toList();
    await preferences.setStringList(_visionBoardsKey, jsonList);
  }
}
