import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';
import 'package:selfsight/domain/entities/goal/priority.dart';
import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/presentation/view/goal/goal_viewmodel.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:stacked_services/stacked_services.dart';

class MockNavigationService extends Mock implements NavigationService {}

class MockGoalService extends Mock implements GoalService {}

// Fake pour enregistrer une valeur de repli pour Goal (requis pour any<Goal>())
class FakeGoal extends Fake implements Goal {}

void main() {
  late MockNavigationService mockNavigationService;
  late MockGoalService mockGoalService;

  setUpAll(() {
    registerFallbackValue(FakeGoal());
  });

  setUp(() {
    mockNavigationService = MockNavigationService();
    mockGoalService = MockGoalService();

    // Remplacer les services dans le locator
    locator.registerSingleton<NavigationService>(mockNavigationService);
    locator.registerSingleton<GoalService>(mockGoalService);
  });

  tearDown(() {
    locator.reset();
  });

  // Données préparés
  const testGoalId = 'goal_123';
  const testTitle = 'Test Goal';
  const testCategory = Category.personalGrowth;
  final testProgress = Progress(
    isAccomplished: false,
    startDate: DateTime(2025, 1, 1),
    endDate: DateTime(2025, 12, 31),
    priority: Priority.medium,
  );
  final testGoal = Goal(
    id: testGoalId,
    title: testTitle,
    progress: testProgress,
    category: testCategory,
    createAt: DateTime.now().toIso8601String(),
  );

  group('loadGoal', () {
    test(
      'Le but est chargé lorsque goalId est valide',
      () async {
        // Arrange
        when(() => mockGoalService.getGoalById(testGoalId))
            .thenAnswer((_) async => testGoal);

        final viewModel = GoalViewModel(goalId: testGoalId);

        // Act
        await viewModel.loadGoal();

        // Assert
        expect(viewModel.goal, equals(testGoal));
        verify(() => mockGoalService.getGoalById(testGoalId)).called(1);
      },
    );

    test(
      'Rien ne se produit lorsque goalId est null',
      () async {
        // Arrange
        final viewModel = GoalViewModel(goalId: null);

        // Act
        await viewModel.loadGoal();

        // Assert
        expect(viewModel.goal, isNull);
        verifyNever(() => mockGoalService.getGoalById(any()));
      },
    );
  });

  group('addGoal', () {
    test(
      'titre valide + catégorie valide + progress valide -> Goal créé et sauvegardé, goalId mis à jour',
      () async {
        // Arrange
        when(() => mockGoalService.saveGoal(any<Goal>()))
            .thenAnswer((_) async => Future.value());
        final viewModel = GoalViewModel();
        const title = 'Nouveau but';
        final category = Category.healthFitness;
        final progress = Progress(
          isAccomplished: false,
          startDate: DateTime.now(),
          priority: Priority.high,
        );

        // Act
        await viewModel.addGoal(title, category, progress);

        // Assert
        // Récupérer le Goal passé à saveGoal
        final captured = verify(() => mockGoalService.saveGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.title, title);
        expect(captured.category, category);
        expect(captured.progress, progress);

        // Vérifier que le viewModel a bien mis à jour son goalId
        expect(viewModel.goalId, isNotNull);
        expect(viewModel.goalId, captured.id);
        expect(viewModel.goal, captured);
      },
    );
  });

  group('deleteGoal', () {
    test(
      'lorsque effacer -> goalId est null et le id du goal ne se trouve pas dans la liste des goals',
      () async {
        // Arrange
        final viewModel = GoalViewModel(goalId: testGoalId);
        // Simuler que le goal existe dans le service (pour la suppression)
        when(() => mockGoalService.deleteGoal(testGoalId))
            .thenAnswer((_) async => Future.value());
        // Simuler la navigation vers Home (appelée dans deleteGoal)
        when(() => mockNavigationService.navigateTo(Routes.homeView))
            .thenAnswer((_) async => Future.value());

        // Act
        await viewModel.deleteGoal();

        // Assert
        expect(viewModel.goalId, isNull);
        verify(() => mockGoalService.deleteGoal(testGoalId)).called(1);
        verify(() => mockNavigationService.navigateTo(Routes.homeView))
            .called(1);
      },
    );
  });

  group('updateGoal', () {
    test(
      'Les changements sont effectivement effectués et le goalId reste pareil',
      () async {
        // Arrange
        //1. On charge un goal initial
        when(() => mockGoalService.getGoalById(testGoalId))
            .thenAnswer((_) async => testGoal);
        when(() => mockGoalService.updateGoal(any()))
            .thenAnswer((_) async => Future.value());

        final viewModel = GoalViewModel(goalId: testGoalId);
        await viewModel.loadGoal();

        // 2. Nouvelles valeurs
        const newTitle = 'But mis à jour';
        final newCategory = Category.careerEducation;
        final newProgress = Progress(
          isAccomplished: true,
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 6, 30),
          priority: Priority.low,
        );

        // Act
        await viewModel.updateGoal(newTitle, newCategory, newProgress);

        // Assert
        // 1. Vérifier que les propriétés du goal ont changé
        expect(viewModel.goal?.title, newTitle);
        expect(viewModel.goal?.category, newCategory);
        expect(viewModel.goal?.progress, newProgress);
        // 2. L'id reste inchangé
        expect(viewModel.goal?.id, testGoalId);
        expect(viewModel.goalId, testGoalId);

        // 3. Vérifier que le service a bien été appelé avec le goal mis à jour
        final captured = verify(() => mockGoalService.updateGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.id, testGoalId);
        expect(captured.title, newTitle);
        expect(captured.category, newCategory);
        expect(captured.progress, newProgress);
      },
    );
  });
}
