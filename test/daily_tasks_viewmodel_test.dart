import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';
import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:selfsight/domain/entities/task/frequency.dart';
import 'package:selfsight/domain/entities/task/task.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/presentation/view/daily_tasks/daily_tasks_viewmodel.dart';
import 'package:selfsight/presentation/view/goal/task/task_helpers.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:selfsight/services/task_service.dart';
import 'package:selfsight/services/vision_board_service.dart';

class MockGoalService extends Mock implements GoalService {}

class MockTaskService extends Mock implements TaskService {}

class MockVisionBoardService extends Mock implements VisionBoardService {}

class MockVisionBoard extends Mock implements VisionBoard {}

class FakeTask extends Fake implements Task {}

void main() {
  late MockGoalService mockGoalService;
  late MockTaskService mockTaskService;
  late MockVisionBoardService mockVisionBoardService;

  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  setUp(() {
    mockGoalService = MockGoalService();
    mockTaskService = MockTaskService();
    mockVisionBoardService = MockVisionBoardService();

    locator.registerSingleton<GoalService>(mockGoalService);
    locator.registerSingleton<TaskService>(mockTaskService);
    locator.registerSingleton<VisionBoardService>(mockVisionBoardService);

    // updateTask is called implicitly on date changes/dispose; stub by default.
    when(() => mockTaskService.updateTask(any()))
        .thenAnswer((_) async => Future.value());
  });

  tearDown(() {
    locator.reset();
  });

  // --- Shared test data ------------------------------------------------

  const testGoalId = 'goal_123';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tenDaysAgo = today.subtract(const Duration(days: 10));

  Goal buildGoal({DateTime? startDate}) => Goal(
        id: testGoalId,
        title: 'Test Goal',
        progress: Progress(
          isAccomplished: false,
          startDate: startDate,
        ),
        category: Category.personalGrowth,
        createAt: today.toIso8601String(),
      );

  Task buildTask({
    required String id,
    int target = 1,
    Map<String, int>? progressLog,
  }) =>
      Task(
        id: id,
        goalId: testGoalId,
        name: 'Task $id',
        frequency: Frequency(
          unit: Unit.count,
          amount: Amount.day,
          days: Day.values, // always visible, regardless of weekday
          time: target,
        ),
        progressLog: progressLog ?? {},
      );

  void stubServices({
    required Goal goal,
    required List<Task> tasks,
    VisionBoard? visionBoard,
  }) {
    when(() => mockGoalService.getGoalById(testGoalId))
        .thenAnswer((_) async => goal);
    when(() => mockTaskService.getTasksByGoalId(testGoalId))
        .thenAnswer((_) async => tasks);
    when(() => mockVisionBoardService.getVisionBoardByGoalId(testGoalId))
        .thenAnswer((_) async => visionBoard);
  }

  // -----------------------------------------------------------------------

  group('initial state', () {
    test('selectedDate defaults to today (time stripped)', () {
      // Arrange
      final viewModel = DailyTasksViewModel(goalId: testGoalId);

      // Act — nothing, checking the default.

      // Assert
      expect(viewModel.selectedDate, today);
    });

    test('canGoToPreviousDate is true when no goal is loaded yet', () {
      // Arrange
      final viewModel = DailyTasksViewModel(goalId: testGoalId);

      // Act / Assert
      expect(viewModel.canGoToPreviousDate, isTrue);
    });

    test('canGoToNextDate is false before today has been exceeded', () {
      // Arrange
      final viewModel = DailyTasksViewModel(goalId: testGoalId);

      // Act / Assert
      expect(viewModel.canGoToNextDate, isFalse);
    });
  });

  group('load', () {
    test('loads goal, vision board path, and splits tasks by completion',
        () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      final incompleteTask = buildTask(id: '2', target: 1);
      final completeTask = buildTask(
        id: '1',
        target: 1,
        progressLog: {progressKeyFor(today, Amount.day): 1},
      );
      final mockVisionBoard = MockVisionBoard();
      when(() => mockVisionBoard.snapshotPath).thenReturn('some/path.png');

      stubServices(
        goal: goal,
        tasks: [incompleteTask, completeTask],
        visionBoard: mockVisionBoard,
      );

      final viewModel = DailyTasksViewModel(goalId: testGoalId);

      // Act
      await viewModel.load();

      // Assert
      expect(viewModel.goal, goal);
      expect(viewModel.visionBoardSnapshotPath, 'some/path.png');
      expect(viewModel.incompleteTasks.map((t) => t.id), ['2']);
      expect(viewModel.completedTasks.map((t) => t.id), ['1']);
      verify(() => mockGoalService.getGoalById(testGoalId)).called(1);
    });

    test('sorts both incomplete and complete lists by task id ascending',
        () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      final taskB = buildTask(id: 'b', target: 5); // incomplete
      final taskA = buildTask(id: 'a', target: 5); // incomplete
      stubServices(goal: goal, tasks: [taskB, taskA]);

      final viewModel = DailyTasksViewModel(goalId: testGoalId);

      // Act
      await viewModel.load();

      // Assert
      expect(viewModel.incompleteTasks.map((t) => t.id), ['a', 'b']);
    });

    test('sets busy to false and notifies once loading completes', () async {
      // Arrange
      final goal = buildGoal();
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);

      // Act
      await viewModel.load();

      // Assert
      expect(viewModel.isBusy, isFalse);
    });
  });

  group('date bounds', () {
    test('canGoToPreviousDate is false once selectedDate reaches startDate',
        () async {
      // Arrange
      final goal = buildGoal(startDate: today);
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();

      // Act / Assert
      expect(viewModel.canGoToPreviousDate, isFalse);
    });

    test('canGoToPreviousDate is true when selectedDate is after startDate',
        () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();

      // Act / Assert
      expect(viewModel.canGoToPreviousDate, isTrue);
    });
  });

  group('goToPreviousDate', () {
    test('moves selectedDate back one day and reloads when within bounds',
        () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load(); // initial load call #1

      // Act
      await viewModel.goToPreviousDate();

      // Assert
      expect(viewModel.selectedDate, today.subtract(const Duration(days: 1)));
      verify(() => mockGoalService.getGoalById(testGoalId)).called(2);
    });

    test('does nothing when selectedDate is already at startDate', () async {
      // Arrange
      final goal = buildGoal(startDate: today);
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load(); // call #1

      // Act
      await viewModel.goToPreviousDate();

      // Assert
      expect(viewModel.selectedDate, today);
      verify(() => mockGoalService.getGoalById(testGoalId)).called(1);
    });

    test('persists current tasks before moving to the previous date', () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      final task = buildTask(id: '1', target: 1);
      stubServices(goal: goal, tasks: [task]);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();

      // Act
      await viewModel.goToPreviousDate();

      // Assert
      verify(() => mockTaskService.updateTask(any())).called(greaterThan(0));
    });
  });

  group('goToNextDate', () {
    test('does nothing when selectedDate is already today', () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load(); // call #1

      // Act
      await viewModel.goToNextDate();

      // Assert
      expect(viewModel.selectedDate, today);
      verify(() => mockGoalService.getGoalById(testGoalId)).called(1);
    });

    test('advances selectedDate back to today after going backward', () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();
      await viewModel.goToPreviousDate();

      // Act
      await viewModel.goToNextDate();

      // Assert
      expect(viewModel.selectedDate, today);
      expect(viewModel.canGoToNextDate, isFalse);
    });
  });

  group('goToDate', () {
    test('clamps to startDateBound when the requested date is earlier',
        () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();

      // Act
      await viewModel.goToDate(tenDaysAgo.subtract(const Duration(days: 5)));

      // Assert
      expect(viewModel.selectedDate, tenDaysAgo);
    });

    test('clamps to today when the requested date is in the future', () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();

      // Act
      await viewModel.goToDate(today.add(const Duration(days: 3)));

      // Assert
      expect(viewModel.selectedDate, today);
    });

    test('does not reload when the requested date equals the current one',
        () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load(); // call #1

      // Act
      await viewModel.goToDate(today);

      // Assert
      verify(() => mockGoalService.getGoalById(testGoalId)).called(1);
    });

    test('updates selectedDate and reloads for a valid in-range date',
        () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load(); // call #1
      final targetDate = today.subtract(const Duration(days: 3));

      // Act
      await viewModel.goToDate(targetDate);

      // Assert
      expect(viewModel.selectedDate, targetDate);
      verify(() => mockGoalService.getGoalById(testGoalId)).called(2);
    });
  });

  group('adjustProgress', () {
    test('moves a task from incomplete to complete once target is reached',
        () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      final task = buildTask(id: '1', target: 1); // starts incomplete
      stubServices(goal: goal, tasks: [task]);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();
      final loadedTask = viewModel.incompleteTasks.first;

      // Act
      await viewModel.adjustProgress(loadedTask, 1);

      // Assert
      expect(viewModel.incompleteTasks, isEmpty);
      expect(viewModel.completedTasks.map((t) => t.id), ['1']);
    });

    test('moves a task from complete back to incomplete when progress drops',
        () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      final task = buildTask(
        id: '1',
        target: 1,
        progressLog: {progressKeyFor(today, Amount.day): 1},
      ); // starts complete
      stubServices(goal: goal, tasks: [task]);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();
      final loadedTask = viewModel.completedTasks.first;

      // Act
      await viewModel.adjustProgress(loadedTask, -1);

      // Assert
      expect(viewModel.completedTasks, isEmpty);
      expect(viewModel.incompleteTasks.map((t) => t.id), ['1']);
    });

    test('removes the progress log entry entirely when value drops to zero',
        () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      final key = progressKeyFor(today, Amount.day);
      final task = buildTask(id: '1', target: 2, progressLog: {key: 1});
      stubServices(goal: goal, tasks: [task]);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();
      final loadedTask = viewModel.incompleteTasks.first;

      // Act
      await viewModel.adjustProgress(loadedTask, -1);

      // Assert
      final updatedTask = viewModel.incompleteTasks.first;
      expect(updatedTask.progressLog.containsKey(key), isFalse);
    });

    test('clamps progress so it never exceeds the target', () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      final key = progressKeyFor(today, Amount.day);
      final task = buildTask(id: '1', target: 1, progressLog: {key: 1});
      stubServices(goal: goal, tasks: [task]);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();
      final loadedTask = viewModel.completedTasks.first;

      // Act
      await viewModel.adjustProgress(loadedTask, 1);

      // Assert
      final updatedTask = viewModel.completedTasks.first;
      expect(updatedTask.progressLog[key], 1);
    });

    test('does nothing when the task is not present in either list', () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      stubServices(goal: goal, tasks: []);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();
      final unrelatedTask = buildTask(id: 'ghost', target: 1);

      // Act
      await viewModel.adjustProgress(unrelatedTask, 1);

      // Assert
      expect(viewModel.incompleteTasks, isEmpty);
      expect(viewModel.completedTasks, isEmpty);
    });
  });

  group('dispose', () {
    test('persists every completed and incomplete task', () async {
      // Arrange
      final goal = buildGoal(startDate: tenDaysAgo);
      final incompleteTask = buildTask(id: '1', target: 1);
      final completeTask = buildTask(
        id: '2',
        target: 1,
        progressLog: {progressKeyFor(today, Amount.day): 1},
      );
      stubServices(goal: goal, tasks: [incompleteTask, completeTask]);
      final viewModel = DailyTasksViewModel(goalId: testGoalId);
      await viewModel.load();

      // Act
      viewModel.dispose();
      await Future<void>.delayed(Duration.zero);

      // Assert
      verify(() => mockTaskService.updateTask(any())).called(2);
    });
  });
}
