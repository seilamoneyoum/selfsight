import 'package:selfsight/domain/entities/task/frequency.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board.dart';
import 'package:selfsight/presentation/view/daily_tasks/date_navigator_logic.dart';
import 'package:selfsight/services/vision_board_service.dart';
import 'package:stacked/stacked.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/services/task_service.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:selfsight/domain/entities/task/task.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';
import 'package:selfsight/presentation/view/goal/task/task_helpers.dart';

class DailyTasksViewModel extends BaseViewModel {
  late final DateNavigatorLogic dateNavigatorLogic;
  final _taskService = locator<TaskService>();
  final _goalService = locator<GoalService>();
  final _visionBoardService = locator<VisionBoardService>();
  final String goalId;

  DailyTasksViewModel({required this.goalId}) {
    dateNavigatorLogic = DateNavigatorLogic(viewModel: this);
  }

  List<Task> _completeTasks = [];
  List<Task> get completedTasks => _completeTasks;
  List<Task> _incompleteTasks = [];
  List<Task> get incompleteTasks => _incompleteTasks;

  Goal? _goal;
  Goal? get goal => _goal;
  String? _visionBoardSnapshotPath;
  String? get visionBoardSnapshotPath => _visionBoardSnapshotPath;
  bool isCompleteTaskListExpanded = false;

  @override
  void dispose() {
    persistCurrentLists();
    super.dispose();
  }

  Future<void> persistCurrentLists() async {
    final allTasks = [..._completeTasks, ..._incompleteTasks];
    for (final task in allTasks) {
      await _taskService.updateTask(task);
    }
  }

  Future<void> load() async {
    setBusy(true);
    _goal = await _goalService.getGoalById(goalId);
    List<Task> allTasks = await _taskService.getTasksByGoalId(goalId);

    VisionBoard? visionBoard =
        await _visionBoardService.getVisionBoardByGoalId(goalId);
    _visionBoardSnapshotPath = visionBoard?.snapshotPath;
    _completeTasks = [];
    _incompleteTasks = [];

    for (Task task in allTasks) {
      if (!isTaskVisibleOn(task, dateNavigatorLogic.selectedDate)) continue;

      if (isTaskCompletedOn(task, dateNavigatorLogic.selectedDate)) {
        _completeTasks.add(task);
      } else {
        _incompleteTasks.add(task);
      }
    }
    _sortLists();
    setBusy(false);
    notifyListeners();
  }

  void _sortLists() {
    _incompleteTasks.sort((a, b) => a.id.compareTo(b.id));
    _completeTasks.sort((a, b) => a.id.compareTo(b.id));
  }

  int progressFor(Task task) =>
      currentProgressFor(task, dateNavigatorLogic.selectedDate);

  bool isCompleted(Task task) =>
      isTaskCompletedOn(task, dateNavigatorLogic.selectedDate);

  /// Incrémente/décrémente la progression
  Future<void> adjustProgress(Task task, int delta) async {
    final key = progressKeyFor(
        dateNavigatorLogic.selectedDate, task.frequency.amount ?? Amount.day);
    final target = task.frequency.time ?? 1;
    final current = task.progressLog[key] ?? 0;
    final newValue = (current + delta).clamp(0, target);

    int incompleteIndex = _incompleteTasks.indexWhere((t) => t.id == task.id);
    int completeIndex = _completeTasks.indexWhere((t) => t.id == task.id);

    if (incompleteIndex == -1 && completeIndex == -1) return;

    bool isIncomplete = incompleteIndex != -1;
    List<Task> sourceList = isIncomplete ? _incompleteTasks : _completeTasks;
    int index = isIncomplete ? incompleteIndex : completeIndex;

    final updatedLog = Map<String, int>.from(sourceList[index].progressLog);
    if (newValue <= 0) {
      updatedLog.remove(key);
    } else {
      updatedLog[key] = newValue;
    }

    final updatedTask = task.copyWith(progressLog: updatedLog);

    bool isNowComplete = newValue >= target;

    sourceList.removeAt(index);

    if (isNowComplete) {
      _completeTasks.add(updatedTask);
    } else {
      _incompleteTasks.add(updatedTask);
    }
    _sortLists();
    notifyListeners();
  }
}
