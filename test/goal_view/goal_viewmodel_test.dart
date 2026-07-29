import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';
import 'package:selfsight/domain/entities/goal/priority.dart';
import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/presentation/view/goal/goal_viewmodel.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:stacked_services/stacked_services.dart';

@GenerateMocks([GoalService, NavigationService])
import 'mocks/goal_viewmodel_test.mocks.dart';

void main() {
  late GoalViewModel viewModel;
  late MockGoalService mockGoalService;
  late MockNavigationService mockNavigationService;

  setUp(() {
    mockGoalService = MockGoalService();
    mockNavigationService = MockNavigationService();

    locator.registerSingleton<GoalService>(mockGoalService);
    locator.registerSingleton<NavigationService>(mockNavigationService);

    viewModel = GoalViewModel(goalId: null);
  });

  tearDown(() {
    locator.reset();
  });

  group('GoalViewModel', () {
    test(
        'loadGoal appelle getGoalById and modifie goal lorsque goalId est donné',
        () async {
      const goalId = '123';
      final expectedGoal = Goal(
        id: goalId,
        title: 'Test',
        visionBoardPath: null,
        progress: Progress(isAccomplished: false),
        category: Category.healthFitness,
        tasks: [],
        createAt: DateTime.now().toIso8601String(),
      );

      // Mockito stubbing
      when(mockGoalService.getGoalById(goalId))
          .thenAnswer((_) async => expectedGoal);

      final viewModelWithId = GoalViewModel(goalId: goalId);
      await viewModelWithId.loadGoal();

      expect(viewModelWithId.goal, expectedGoal);
      verify(mockGoalService.getGoalById(goalId)).called(1);
    });

    test('loadGoal ne fait rien lorsque goalId est null', () async {
      await viewModel.loadGoal();
      verifyNever(mockGoalService.getGoalById(any));
    });

    test('addGoal sauvegarde un nouveau objectif avec les bons informations',
        () async {
      const title = 'New Goal';
      final category = Category.careerEducation;
      final progress = Progress(
        isAccomplished: false,
        priority: Priority.high,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
      );

      when(mockGoalService.saveGoal(any)).thenAnswer((_) async {});

      await viewModel.addGoal(title, category, progress);

      verify(mockGoalService.saveGoal(any)).called(1);
      final captured =
          verify(mockGoalService.saveGoal(captureAny)).captured.single as Goal;

      expect(captured.title, title);
      expect(captured.category, category);
      expect(captured.progress, progress);
      expect(captured.tasks, isEmpty);
      expect(captured.visionBoardPath, isNull);
      expect(captured.createAt, isNotNull);
    });

    test(
        'navigateToHomeGoalView appelle navigation service avec la route de homeView',
        () {
      viewModel.navigateToHomeGoalView();
      verify(mockNavigationService.navigateTo(Routes.homeView)).called(1);
    });

    test(
        'navigateToVisionBoardView appelle navigation service avec la route de visionBoardView',
        () {
      viewModel.navigateToVisionBoardView();
      verify(mockNavigationService.navigateTo(Routes.visionBoardView))
          .called(1);
    });
  });
}
