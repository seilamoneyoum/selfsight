import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selfsight/domain/entities/task/frequency.dart';
import 'package:selfsight/domain/entities/task/task.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/presentation/view/goal/task/task_viewmodel.dart';
import 'package:selfsight/services/task_service.dart';

class MockTaskService extends Mock implements TaskService {}

class FakeTask extends Fake implements Task {}

void main() {
  late MockTaskService mockTaskService;

  setUpAll(() {
    registerFallbackValue(FakeTask());
  });

  setUp(() {
    mockTaskService = MockTaskService();
    locator.registerSingleton<TaskService>(mockTaskService);
  });

  tearDown(() {
    locator.reset();
  });

  final frequency = Frequency(unit: Unit.minutes, time: 20, days: [Day.monday]);

  group('Goal not yet saved (goalId == null)', () {
    test('addTask adds the task locally without calling saveTask', () async {
      // Arrange
      final viewModel = TaskViewModel(goalId: null);

      // Act
      await viewModel.addTask('Méditation', frequency);

      // Assert
      expect(viewModel.tasks.length, 1);
      expect(viewModel.tasks.first.name, 'Méditation');
      verifyNever(() => mockTaskService.saveTask(any()));
    });

    test('updateTask updates the task locally without calling the service',
        () async {
      // Arrange
      final viewModel = TaskViewModel(goalId: null);
      await viewModel.addTask('Ancien nom', frequency);
      viewModel.startEditingTask(viewModel.tasks.first.id);

      // Act
      await viewModel.updateTask('Nouveau nom', frequency);

      // Assert
      expect(viewModel.tasks.first.name, 'Nouveau nom');
      verifyNever(() => mockTaskService.updateTask(any()));
    });

    test('deleteTask removes the task locally without calling the service',
        () async {
      // Arrange
      final viewModel = TaskViewModel(goalId: null);
      await viewModel.addTask('À supprimer', frequency);
      final id = viewModel.tasks.first.id;

      // Act
      await viewModel.deleteTask(id);

      // Assert
      expect(viewModel.tasks, isEmpty);
      verifyNever(() => mockTaskService.deleteTask(any()));
      verifyNever(() => mockTaskService.deleteTasksByGoalId(any()));
    });

    test('loadTasks does not call the service and leaves the list empty',
        () async {
      // Arrange
      final viewModel = TaskViewModel(goalId: null);

      // Act
      await viewModel.loadTasks();

      // Assert
      expect(viewModel.tasks, isEmpty);
      verifyNever(() => mockTaskService.getTasksByGoalId(any()));
    });
  });

  group('Goal already saved (goalId != null)', () {
    const goalId = 'goal_123';

    test('addTask persists the task through saveTask', () async {
      // Arrange
      when(() => mockTaskService.saveTask(any())).thenAnswer((_) async {});
      final viewModel = TaskViewModel(goalId: goalId);

      // Act
      await viewModel.addTask('Lecture', frequency);

      // Assert
      final captured = verify(() => mockTaskService.saveTask(captureAny()))
          .captured
          .single as Task;
      expect(captured.name, 'Lecture');
      expect(captured.goalId, goalId);
    });

    test('updateTask persists the change through updateTask', () async {
      // Arrange
      when(() => mockTaskService.saveTask(any())).thenAnswer((_) async {});
      when(() => mockTaskService.updateTask(any())).thenAnswer((_) async {});
      final viewModel = TaskViewModel(goalId: goalId);
      await viewModel.addTask('Ancien nom', frequency);
      viewModel.startEditingTask(viewModel.tasks.first.id);

      // Act
      await viewModel.updateTask('Nouveau nom', frequency);

      // Assert
      verify(() => mockTaskService.updateTask(any())).called(1);
      expect(viewModel.tasks.first.name, 'Nouveau nom');
    });

    test('deleteTask persists the deletion through deleteTask', () async {
      // Arrange
      when(() => mockTaskService.saveTask(any())).thenAnswer((_) async {});
      when(() => mockTaskService.deleteTask(any())).thenAnswer((_) async {});
      final viewModel = TaskViewModel(goalId: goalId);
      await viewModel.addTask('À supprimer', frequency);
      final id = viewModel.tasks.first.id;

      // Act
      await viewModel.deleteTask(id);

      // Assert
      verify(() => mockTaskService.deleteTask(id)).called(1);
      expect(viewModel.tasks, isEmpty);
    });

    test('loadTasks fetches tasks from the service', () async {
      // Arrange
      final existingTask = Task(
          id: 't1', goalId: goalId, name: 'Existant', frequency: frequency);
      when(() => mockTaskService.getTasksByGoalId(goalId))
          .thenAnswer((_) async => [existingTask]);
      final viewModel = TaskViewModel(goalId: goalId);

      // Act
      await viewModel.loadTasks();

      // Assert
      expect(viewModel.tasks, [existingTask]);
    });
  });
}
