// task_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:selfsight/domain/entities/task/task.dart';

class TaskService {
  static const String _tasksKey = 'tasks_list';

  /// Sauvegarder une tâche (nouvelle ou existante)
  /// Par le principe d'un mise à jour, on enlève l'ancienne version,
  /// et la remplace par une nouvelle version.
  Future<void> saveTask(Task task) async {
    final preferences = await SharedPreferences.getInstance();
    List<Task> currentTasks = await getTasks();

    currentTasks.removeWhere((t) => t.id == task.id);
    currentTasks.add(task);

    List<String> jsonList =
        currentTasks.map((t) => jsonEncode(t.toJson())).toList();

    await preferences.setStringList(_tasksKey, jsonList);
  }

  // Charger toutes les tâches sauvegardées
  Future<List<Task>> getTasks() async {
    final preferences = await SharedPreferences.getInstance();
    List<String>? jsonList = preferences.getStringList(_tasksKey);

    if (jsonList == null || jsonList.isEmpty) return [];

    return jsonList.map((jsonString) {
      Map<String, dynamic> jsonMap = jsonDecode(jsonString);
      return Task.fromJson(jsonMap);
    }).toList();
  }

  // Charger toutes les tâches liées à un objectif en particulier
  Future<List<Task>> getTasksByGoalId(String goalId) async {
    List<Task> allTasks = await getTasks();
    return allTasks.where((t) => t.goalId == goalId).toList();
  }

  // Obtenir une tâche via ID
  Future<Task> getTaskById(String id) async {
    List<Task> allTasks = await getTasks();
    return allTasks.firstWhere((t) => t.id == id);
  }

  // Effacer une tâche via ID
  Future<void> deleteTask(String id) async {
    final preferences = await SharedPreferences.getInstance();
    List<Task> currentTasks = await getTasks();

    currentTasks.removeWhere((t) => t.id == id);

    List<String> jsonList =
        currentTasks.map((t) => jsonEncode(t.toJson())).toList();
    await preferences.setStringList(_tasksKey, jsonList);
  }

  // Effacer toutes les tâches liées à un objectif (ex: à la suppression du goal)
  Future<void> deleteTasksByGoalId(String goalId) async {
    final preferences = await SharedPreferences.getInstance();
    List<Task> currentTasks = await getTasks();

    currentTasks.removeWhere((t) => t.goalId == goalId);

    List<String> jsonList =
        currentTasks.map((t) => jsonEncode(t.toJson())).toList();
    await preferences.setStringList(_tasksKey, jsonList);
  }

  // Mise à jour de la tâche plus conventiel
  Future<void> updateTask(Task updatedTask) async {
    await saveTask(updatedTask);
  }
}
