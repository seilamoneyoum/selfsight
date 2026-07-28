import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';

class GoalService {
  static const String _goalsKey = 'goals_list';

  /// Sauvegarder l'image de "Vision Board" comme étant une fichier
  Future<String?> saveVisionBoardImage(Uint8List imageBytes) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String fileName =
          'vision_board_${DateTime.now().millisecondsSinceEpoch}.png';
      final String filePath = '${appDocDir.path}/$fileName';

      final File file = File(filePath);
      await file.writeAsBytes(imageBytes);
      return filePath;
    } catch (e) {
      return null;
    }
  }

  /// Effacer un image fichier lorsqu'un objectif est enlevé
  Future<void> deleteImageFile(String? path) async {
    if (path == null) return;
    try {
      final File file = File(path);
      if (await file.exists()) await file.delete();
    } catch (e) {
      // Rien, mais on ignore les erreurs.
    }
  }

  /// Sauvegarder un objectif
  /// Par le principe d'un mise à jour, on enlève l'ancien version,
  /// et le remplace par une nouvelle version.
  Future<void> saveGoal(Goal goal) async {
    final preferences = await SharedPreferences.getInstance();
    List<Goal> currentGoals = await loadGoals();

    currentGoals.removeWhere((g) => g.id == goal.id);
    currentGoals.add(goal);

    List<String> jsonList =
        currentGoals.map((g) => jsonEncode(g.toJson())).toList();

    await preferences.setStringList(_goalsKey, jsonList);
  }

  // Charger tous les objectifs sauvegardés
  Future<List<Goal>> loadGoals() async {
    final preferences = await SharedPreferences.getInstance();
    List<String>? jsonList = preferences.getStringList(_goalsKey);

    if (jsonList == null || jsonList.isEmpty) return [];

    return jsonList.map((jsonString) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return Goal.fromJson(jsonMap);
    }).toList();
  }

  // Effacer un objectif via ID (et, par extension, le fichier image de vision board
  Future<void> deleteGoal(String id) async {
    final preferences = await SharedPreferences.getInstance();
    List<Goal> currentGoals = await loadGoals();

    final goalToDelete = currentGoals.firstWhere((g) => g.id == id);
    await deleteImageFile(goalToDelete.visionBoardPath);

    currentGoals.removeWhere((g) => g.id == id);

    List<String> jsonList =
        currentGoals.map((g) => jsonEncode(g.toJson())).toList();
    await preferences.setStringList(_goalsKey, jsonList);
  }

  // Mise à jour du objectif plus conventiel
  Future<void> updateGoal(Goal updatedGoal) async {
    await saveGoal(updatedGoal);
  }
}
