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

  String? _editingId;
  String? get editingId => _editingId;

  Task? get editingTask =>
      _editingId != null ? _tasks.firstWhere((t) => t.id == _editingId) : null;

  /// Charger les tâches existantes liées à cet objectif.
  /// Si le goal n'a pas encore été sauvegardé, il n'y a rien à charger.
  Future<void> loadTasks() async {
    if (goalId == null) return;
    try {
      setBusy(true);
      _tasks = await _taskService.getTasksByGoalId(goalId!);
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  void startAddingTask() {
    _editingId = null;
    notifyListeners();
  }

  void startEditingTask(String id) {
    _editingId = id;
    notifyListeners();
  }

  void cancelEditing() {
    _editingId = null;
    notifyListeners();
  }

  /// Ajoute une nouvelle tâche. Persistée seulement si le goal est déjà sauvegardé.
  Future<void> addTask(String name, Frequency frequency) async {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      goalId: goalId ?? '',
      name: name,
      frequency: frequency,
    );

    if (goalId != null) {
      await _taskService.saveTask(task);
    }
    _tasks.add(task);
    notifyListeners();
  }

  /// Met à jour la tâche en édition. Persistée seulement si le goal est déjà sauvegardé.
  Future<void> updateTask(String name, Frequency frequency) async {
    if (_editingId == null) return;

    final index = _tasks.indexWhere((t) => t.id == _editingId);
    if (index == -1) return;

    final updated = Task(
      id: _editingId!,
      goalId: goalId ?? '',
      name: name,
      frequency: frequency,
    );

    if (goalId != null) {
      await _taskService.updateTask(updated);
    }
    _tasks[index] = updated;
    _editingId = null;
    notifyListeners();
  }

  /// Supprime une tâche. Persistée seulement si le goal est déjà sauvegardé.
  Future<void> deleteTask(String id) async {
    if (goalId != null) {
      await _taskService.deleteTask(id);
    }
    _tasks.removeWhere((t) => t.id == id);
    if (_editingId == id) {
      _editingId = null;
    }
    notifyListeners();
  }
}
