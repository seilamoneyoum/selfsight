import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';
import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:selfsight/domain/entities/task/task.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board.dart';
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/presentation/view/daily_tasks/daily_tasks_sheet.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:selfsight/services/task_service.dart';
import 'package:selfsight/services/vision_board_service.dart';

class MockGoalService extends Mock implements GoalService {}

class MockTaskService extends Mock implements TaskService {}

class MockVisionBoardService extends Mock implements VisionBoardService {}

class MockVisionBoard extends Mock implements VisionBoard {}

class FakeTask extends Fake implements Task {}

String expectedDateLabel(DateTime date) {
  final now = DateTime.now();
  final isToday =
      date.year == now.year && date.month == now.month && date.day == now.day;
  if (isToday) return "Today";
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return "${months[date.month - 1]} ${date.day}, ${date.year}";
}

void main() {
  late MockGoalService mockGoalService;
  late MockTaskService mockTaskService;
  late MockVisionBoardService mockVisionBoardService;

  const testGoalId = 'goal_123';

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tenDaysAgo = today.subtract(const Duration(days: 10));

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

    when(() => mockTaskService.updateTask(any()))
        .thenAnswer((_) async => Future.value());
  });

  tearDown(() {
    locator.reset();
  });

  // ==================== Helpers ====================
  Goal buildGoal({DateTime? startDate}) => Goal(
        id: testGoalId,
        title: 'Test Goal',
        progress: Progress(isAccomplished: false, startDate: startDate),
        category: Category.personalGrowth,
        createAt: today.toIso8601String(),
      );

  /* Task buildTask({
    required String id,
    required String name,
    int target = 1,
    Map<String, int>? progressLog,
  }) =>
      Task(
        id: id,
        goalId: testGoalId,
        name: name,
        frequency: Frequency(
          unit: Unit.count,
          amount: Amount.day,
          days: Day.values,
          time: target,
        ),
        progressLog: progressLog ?? {},
      );
*/
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

  Widget buildSheetWidget() {
    return MaterialApp(
      home: Scaffold(
        body: DailyTasksSheet(goalId: testGoalId),
      ),
    );
  }

  // ==================== LOADING STATE ====================

  group('Loading state', () {
    testWidgets('shows a progress indicator until the goal finishes loading',
        (tester) async {
      // Arrange
      final completer = Completer<Goal>();
      when(() => mockGoalService.getGoalById(testGoalId))
          .thenAnswer((_) => completer.future);
      when(() => mockTaskService.getTasksByGoalId(testGoalId))
          .thenAnswer((_) async => []);
      when(() => mockVisionBoardService.getVisionBoardByGoalId(testGoalId))
          .thenAnswer((_) async => null);

      // Act
      await tester.pumpWidget(buildSheetWidget());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete(buildGoal(startDate: tenDaysAgo));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ==================== VISION BOARD ====================

  group('Vision board preview', () {
    testWidgets('shows placeholder text when no vision board snapshot exists',
        (tester) async {
      // Arrange
      stubServices(goal: buildGoal(startDate: tenDaysAgo), tasks: []);

      // Act
      await tester.pumpWidget(buildSheetWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('No vision board yet'), findsOneWidget);
    });
  });

  // ==================== EDIT NAVIGATION ====================

  group('Edit navigation', () {
    testWidgets(
      'tapping Edit closes the sheet and navigates to the goal view',
      (tester) async {
        // Arrange
        stubServices(goal: buildGoal(startDate: tenDaysAgo), tasks: []);

        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) {
              if (settings.name == '/') {
                return MaterialPageRoute(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: ElevatedButton(
                        onPressed: () =>
                            showDailyTasksSheet(context, testGoalId),
                        child: const Text('Open sheet'),
                      ),
                    ),
                  ),
                );
              }
              if (settings.name == Routes.goalView) {
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(body: Text('Goal View')),
                );
              }
              return null;
            },
            initialRoute: '/',
          ),
        );

        await tester.tap(find.text('Open sheet'));
        await tester.pumpAndSettle();

        // Act
        await tester.tap(find.text('Edit'));
        await tester.pumpAndSettle();

        // Assert
        expect(find.text('Goal View'), findsOneWidget);
        expect(find.byType(DailyTasksSheet), findsNothing);
      },
    );
  });
}
