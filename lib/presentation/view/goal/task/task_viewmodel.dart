// task_viewmodel.dart
import 'package:stacked/stacked.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/services/task_service.dart';
import 'package:selfsight/domain/entities/task/task.dart';
import 'package:selfsight/domain/entities/task/frequency.dart';

class TaskViewModel extends BaseViewModel {
  final _taskService = locator<TaskService>();

  String? goalId;
  TaskViewModel({this.goalId});

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  // ID de la tâche en cours de modification (null si on crée une nouvelle tâche)
  String? _editingId;
  String? get editingId => _editingId;

  Task? get editingTask =>
      _editingId != null ? _tasks.firstWhere((t) => t.id == _editingId) : null;

  /// Charger les tâches existantes liées à cet objectif
  Future<void> loadTasks() async {
    try {
      setBusy(true);
      _tasks = await _taskService.getTasksByGoalId(goalId!);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  /// Prépare le formulaire pour l'ajout d'une nouvelle tâche
  void startAddingTask() {
    _editingId = null;
    notifyListeners();
  }

  /// Prépare le formulaire pour la modification d'une tâche existante
  void startEditingTask(String id) {
    _editingId = id;
    notifyListeners();
  }

  /// Réinitialise l'état d'édition (ex: à la fermeture du formulaire)
  void cancelEditing() {
    _editingId = null;
    notifyListeners();
  }

  /// Ajoute une nouvelle tâche
  Future<void> addTask(String name, Frequency frequency) async {
    try {
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        goalId: goalId!,
        name: name,
        frequency: frequency,
      );

      await _taskService.saveTask(task);
      _tasks.add(task);
    } finally {
      notifyListeners();
    }
  }

  /// Met à jour la tâche actuellement sélectionnée pour édition
  Future<void> updateTask(String name, Frequency frequency) async {
    if (_editingId == null) return;

    final index = _tasks.indexWhere((t) => t.id == _editingId);
    if (index == -1) return;

    final updated = Task(
      id: _editingId!,
      goalId: goalId!,
      name: name,
      frequency: frequency,
    );

    await _taskService.updateTask(updated);
    _tasks[index] = updated;
    _editingId = null;
    notifyListeners();
  }

  /// Supprime une tâche
  Future<void> deleteTask(String id) async {
    await _taskService.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    if (_editingId == id) {
      _editingId = null;
    }
    notifyListeners();
  }
}
