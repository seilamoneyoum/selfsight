import 'package:selfsight/domain/entities/task/frequency.dart';
import 'package:stacked/stacked.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/services/task_service.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:selfsight/domain/entities/task/task.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';
import 'package:selfsight/presentation/view/goal/task/task_helpers.dart';

class GoalOverviewViewmodel extends BaseViewModel {
  final _taskService = locator<TaskService>();
  final _goalService = locator<GoalService>();

  final String goalId;
  GoalOverviewViewmodel({required this.goalId});

  Goal? _goal;
  Goal? get goal => _goal;

  List<Task> _allTasks = [];

  /// Tâches visibles aujourd'hui, filtrées selon leur fréquence.
  List<Task> get visibleTasks {
    final today = DateTime.now();
    return _allTasks.where((t) => isTaskVisibleOn(t, today)).toList();
  }

  Future<void> load() async {
    setBusy(true);
    _goal = await _goalService.getGoalById(goalId);
    _allTasks = await _taskService.getTasksByGoalId(goalId);
    setBusy(false);
    notifyListeners();
  }

  int progressFor(Task task) => currentProgressFor(task, DateTime.now());

  bool isCompleted(Task task) => isTaskCompletedOn(task, DateTime.now());

  /// Incrémente/décrémente la progression
  Future<void> adjustProgress(Task task, int delta) async {
    final today = DateTime.now();
    final key = progressKeyFor(today, task.frequency.amount ?? Amount.day);
    final target = task.frequency.time ?? 1;
    final current = task.progressLog[key] ?? 0;
    final newValue = (current + delta).clamp(0, target);

    // Met à jour la copie locale pour un rafraîchissement immédiat
    final index = _allTasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final updatedLog = Map<String, int>.from(_allTasks[index].progressLog);
      if (newValue <= 0) {
        updatedLog.remove(key);
      } else {
        updatedLog[key] = newValue;
      }
      _allTasks[index] = Task(
        id: task.id,
        goalId: task.goalId,
        name: task.name,
        frequency: task.frequency,
        progressLog: updatedLog,
      );
    }
    notifyListeners();
  }

  /// Coche/décoche directement (pour les tâches à cible = 1).
  Future<void> toggle(Task task) async {
    final isDone = isCompleted(task);
    final target = task.frequency.time ?? 1;
    await adjustProgress(task, isDone ? -target : target);
  }
}
