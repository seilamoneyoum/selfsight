import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';
import 'package:selfsight/domain/entities/goal/priority.dart';
import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/presentation/view/goal/goal_form.dart';
import 'package:selfsight/presentation/view/goal/goal_viewmodel.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:stacked_services/stacked_services.dart';

// Mocks
class MockNavigationService extends Mock implements NavigationService {}

class MockGoalService extends Mock implements GoalService {}

// Fake pour registerFallbackValue
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

    locator.registerSingleton<NavigationService>(mockNavigationService);
    locator.registerSingleton<GoalService>(mockGoalService);
  });

  tearDown(() {
    locator.reset();
  });

  // Helpers
  Widget buildGoalForm(GoalViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: GoalForm(viewModel: viewModel),
      ),
    );
  }

  Future<void> selectCategory(WidgetTester tester, Category category) async {
    final categoryField = find.byType(DropdownButtonFormField<Category>);
    await tester.tap(categoryField);
    await tester.pumpAndSettle();
    final categoryItem = find.text(category.title).last;
    await tester.tap(categoryItem);
    await tester.pumpAndSettle();
  }

  Future<void> selectPriority(WidgetTester tester, Priority priority) async {
    final priorityField = find.byType(DropdownButtonFormField<Priority>);
    await tester.tap(priorityField);
    await tester.pumpAndSettle();
    final priorityItem = find.text(priority.level).last;
    await tester.tap(priorityItem);
    await tester.pumpAndSettle();
  }

  Future<void> toggleDateSwitch(WidgetTester tester, String label,
      {required bool turnOn}) async {
    final row = find.widgetWithText(Row, label);
    final switchFinder = find.descendant(
      of: row,
      matching: find.byType(CupertinoSwitch),
    );
    final switchWidget = tester.widget<CupertinoSwitch>(switchFinder);
    if (switchWidget.value != turnOn) {
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
    }
  }

  Future<void> enterTitle(WidgetTester tester, String title) async {
    await tester.enterText(find.byType(TextFormField), title);
    await tester.pumpAndSettle();
  }

  Future<void> tapConfirmButton(WidgetTester tester) async {
    final button = find.widgetWithText(ElevatedButton, 'Confirm');
    if (button.evaluate().isEmpty) {
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    } else {
      await tester.tap(button);
    }
    await tester.pumpAndSettle();
  }

  void expectErrorMessage(WidgetTester tester, String errorText) {
    expect(find.text(errorText), findsOneWidget);
  }

  void expectNoErrorMessage(WidgetTester tester, String errorText) {
    expect(find.text(errorText), findsNothing);
  }

  // ==================== NEW GOAL ====================

  group('New goal', () {
    testWidgets(
      'When all fields are valid, tapping Confirm saves the goal, changes button to Save, and shows no errors',
      (tester) async {
        when(() => mockGoalService.saveGoal(any<Goal>()))
            .thenAnswer((_) async {});
        final viewModel = GoalViewModel();
        await tester.pumpWidget(buildGoalForm(viewModel));

        await enterTitle(tester, 'Mon nouveau but');
        await selectCategory(tester, Category.healthFitness);
        await selectPriority(tester, Priority.high);
        await toggleDateSwitch(tester, 'Start date', turnOn: true);
        await toggleDateSwitch(tester, 'End date', turnOn: true);

        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectNoErrorMessage(tester, 'Title is needed');
        expectNoErrorMessage(tester, 'Category needs to be selected');
        expectNoErrorMessage(tester, 'Priority needs to be selected');
        expectNoErrorMessage(tester, 'End date needs to be after start date');

        expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
        verify(() => mockGoalService.saveGoal(any<Goal>())).called(1);
        final captured = verify(() => mockGoalService.saveGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.title, 'Mon nouveau but');
        expect(captured.category, Category.healthFitness);
        expect(captured.progress.priority, Priority.high);
      },
    );

    testWidgets(
      'When all mandatory fields are valid and isAccomplished is checked, Confirm saves the goal with no dates and no errors',
      (tester) async {
        when(() => mockGoalService.saveGoal(any<Goal>()))
            .thenAnswer((_) async {});
        final viewModel = GoalViewModel();
        await tester.pumpWidget(buildGoalForm(viewModel));

        await enterTitle(tester, 'But avec accompli');
        await selectCategory(tester, Category.careerEducation);
        await selectPriority(tester, Priority.medium);
        final checkbox = find.byType(Checkbox);
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectNoErrorMessage(tester, 'Title is needed');
        expectNoErrorMessage(tester, 'Category needs to be selected');
        expectNoErrorMessage(tester, 'Priority needs to be selected');
        expectNoErrorMessage(tester, 'End date needs to be after start date');

        final captured = verify(() => mockGoalService.saveGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.progress.isAccomplished, isTrue);
        expect(captured.progress.startDate, isNull);
        expect(captured.progress.endDate, isNull);
      },
    );

    testWidgets(
      'When no fields are filled, tapping Confirm shows three error messages and does not save the goal',
      (tester) async {
        when(() => mockGoalService.saveGoal(any<Goal>()))
            .thenAnswer((_) async {});
        final viewModel = GoalViewModel();
        await tester.pumpWidget(buildGoalForm(viewModel));

        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectErrorMessage(tester, 'Title is needed');
        expectErrorMessage(tester, 'Category needs to be selected');
        expectErrorMessage(tester, 'Priority needs to be selected');
        verifyNever(() => mockGoalService.saveGoal(any<Goal>()));
      },
    );

    testWidgets(
      'When title and category are filled but priority is missing, Confirm shows a priority error and does not save',
      (tester) async {
        when(() => mockGoalService.saveGoal(any<Goal>()))
            .thenAnswer((_) async {});
        final viewModel = GoalViewModel();
        await tester.pumpWidget(buildGoalForm(viewModel));

        await enterTitle(tester, 'Titre uniquement');
        await selectCategory(tester, Category.finance);
        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectNoErrorMessage(tester, 'Title is needed');
        expectNoErrorMessage(tester, 'Category needs to be selected');
        expectErrorMessage(tester, 'Priority needs to be selected');
        verifyNever(() => mockGoalService.saveGoal(any<Goal>()));
      },
    );

    testWidgets(
      'After displaying errors, filling all fields correctly and confirming clears errors and saves the goal',
      (tester) async {
        when(() => mockGoalService.saveGoal(any<Goal>()))
            .thenAnswer((_) async {});
        final viewModel = GoalViewModel();
        await tester.pumpWidget(buildGoalForm(viewModel));

        // Generate errors
        await tapConfirmButton(tester);
        await tester.pumpAndSettle();
        expectErrorMessage(tester, 'Title is needed');
        expectErrorMessage(tester, 'Category needs to be selected');
        expectErrorMessage(tester, 'Priority needs to be selected');

        // Fill all fields
        await enterTitle(tester, 'But complet');
        await selectCategory(tester, Category.personalGrowth);
        await selectPriority(tester, Priority.low);
        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectNoErrorMessage(tester, 'Title is needed');
        expectNoErrorMessage(tester, 'Category needs to be selected');
        expectNoErrorMessage(tester, 'Priority needs to be selected');
        verify(() => mockGoalService.saveGoal(any<Goal>())).called(1);
      },
    );

    testWidgets(
      'When end date is before start date, Confirm shows a date error and does not save the goal',
      (tester) async {
        when(() => mockGoalService.saveGoal(any<Goal>()))
            .thenAnswer((_) async {});
        final viewModel = GoalViewModel();
        await tester.pumpWidget(buildGoalForm(viewModel));

        await enterTitle(tester, 'Date invalide');
        await selectCategory(tester, Category.other);
        await selectPriority(tester, Priority.low);
        await toggleDateSwitch(tester, 'Start date', turnOn: true);
        await toggleDateSwitch(tester, 'End date', turnOn: true);

        final formState = tester.state<GoalFormState>(find.byType(GoalForm));
        final now = DateTime.now();
        formState.selectedProgress.startDate = now.add(Duration(days: 1));
        formState.selectedProgress.endDate = now;
        await tester.pumpAndSettle();

        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectErrorMessage(tester, 'End date needs to be after start date');
        verifyNever(() => mockGoalService.saveGoal(any<Goal>()));
      },
    );

    testWidgets(
      'Activating then deactivating the start date toggle results in a null startDate when saving',
      (tester) async {
        when(() => mockGoalService.saveGoal(any<Goal>()))
            .thenAnswer((_) async {});
        final viewModel = GoalViewModel();
        await tester.pumpWidget(buildGoalForm(viewModel));

        await enterTitle(tester, 'Test date toggle');
        await selectCategory(tester, Category.healthFitness);
        await selectPriority(tester, Priority.medium);

        await toggleDateSwitch(tester, 'Start date', turnOn: true);
        final formState = tester.state<GoalFormState>(find.byType(GoalForm));
        formState.selectedProgress.startDate = DateTime(2025, 1, 1);
        await tester.pumpAndSettle();

        await toggleDateSwitch(tester, 'Start date', turnOn: false);
        await tester.pumpAndSettle();

        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        final captured = verify(() => mockGoalService.saveGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.progress.startDate, isNull);
        expect(captured.progress.endDate, isNull);
      },
    );

    testWidgets(
      'Activating then deactivating the end date toggle results in a null endDate when saving',
      (tester) async {
        when(() => mockGoalService.saveGoal(any<Goal>()))
            .thenAnswer((_) async {});
        final viewModel = GoalViewModel();
        await tester.pumpWidget(buildGoalForm(viewModel));

        await enterTitle(tester, 'Test date toggle end');
        await selectCategory(tester, Category.careerEducation);
        await selectPriority(tester, Priority.high);

        await toggleDateSwitch(tester, 'End date', turnOn: true);
        final formState = tester.state<GoalFormState>(find.byType(GoalForm));
        formState.selectedProgress.endDate = DateTime(2025, 12, 31);
        await tester.pumpAndSettle();

        await toggleDateSwitch(tester, 'End date', turnOn: false);
        await tester.pumpAndSettle();

        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        final captured = verify(() => mockGoalService.saveGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.progress.endDate, isNull);
        expect(captured.progress.startDate, isNull);
      },
    );

    testWidgets(
      'Activating both date toggles, setting dates, then deactivating both results in both dates being null',
      (tester) async {
        when(() => mockGoalService.saveGoal(any<Goal>()))
            .thenAnswer((_) async {});
        final viewModel = GoalViewModel();
        await tester.pumpWidget(buildGoalForm(viewModel));

        await enterTitle(tester, 'Test both toggles');
        await selectCategory(tester, Category.finance);
        await selectPriority(tester, Priority.low);

        await toggleDateSwitch(tester, 'Start date', turnOn: true);
        await toggleDateSwitch(tester, 'End date', turnOn: true);
        final formState = tester.state<GoalFormState>(find.byType(GoalForm));
        formState.selectedProgress.startDate = DateTime(2025, 1, 1);
        formState.selectedProgress.endDate = DateTime(2025, 12, 31);
        await tester.pumpAndSettle();

        await toggleDateSwitch(tester, 'Start date', turnOn: false);
        await toggleDateSwitch(tester, 'End date', turnOn: false);
        await tester.pumpAndSettle();

        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        final captured = verify(() => mockGoalService.saveGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.progress.startDate, isNull);
        expect(captured.progress.endDate, isNull);
      },
    );
  });

  // ==================== EXISTING GOAL ====================

  group('Existing goal', () {
    final existingGoal = Goal(
      id: 'existing_123',
      title: 'Ancien but',
      progress: Progress(
        isAccomplished: false,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        priority: Priority.medium,
      ),
      category: Category.healthFitness,
      createAt: DateTime.now().toIso8601String(),
      tasks: [],
      visionBoardPath: null,
    );

    Future<GoalViewModel> setupExistingGoalViewModel(WidgetTester tester,
        {Goal? overrideGoal}) async {
      final goalToUse = overrideGoal ?? existingGoal;
      when(() => mockGoalService.getGoalById(goalToUse.id))
          .thenAnswer((_) async => goalToUse);
      when(() => mockGoalService.updateGoal(any<Goal>()))
          .thenAnswer((_) async {});
      when(() => mockGoalService.saveGoal(any<Goal>()))
          .thenAnswer((_) async {});

      final viewModel = GoalViewModel(goalId: goalToUse.id);
      await viewModel.loadGoal();
      await tester.pumpWidget(buildGoalForm(viewModel));
      await tester.pumpAndSettle();
      return viewModel;
    }

    testWidgets(
      'When all fields are valid, tapping Save updates the goal with the same ID and shows no errors',
      (tester) async {
        final viewModel = await setupExistingGoalViewModel(tester);

        await enterTitle(tester, 'But modifié');
        await selectCategory(tester, Category.careerEducation);
        await selectPriority(tester, Priority.high);
        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectNoErrorMessage(tester, 'Title is needed');
        expectNoErrorMessage(tester, 'Category needs to be selected');
        expectNoErrorMessage(tester, 'Priority needs to be selected');
        expectNoErrorMessage(tester, 'End date needs to be after start date');

        verify(() => mockGoalService.updateGoal(any<Goal>())).called(1);
        final captured = verify(() => mockGoalService.updateGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.id, existingGoal.id);
        expect(captured.title, 'But modifié');
        expect(captured.category, Category.careerEducation);
        expect(captured.progress.priority, Priority.high);
        expect(captured.progress.startDate, existingGoal.progress.startDate);
        expect(captured.progress.endDate, existingGoal.progress.endDate);
      },
    );

    testWidgets(
      'When mandatory fields are valid and isAccomplished is checked, Save updates the goal and clears dates if toggles are off',
      (tester) async {
        final viewModel = await setupExistingGoalViewModel(tester);

        await enterTitle(tester, 'But accompli');
        await selectCategory(tester, Category.finance);
        await selectPriority(tester, Priority.low);
        final checkbox = find.byType(Checkbox);
        await tester.tap(checkbox);
        await tester.pumpAndSettle();

        await toggleDateSwitch(tester, 'Start date', turnOn: false);
        await toggleDateSwitch(tester, 'End date', turnOn: false);
        await tester.pumpAndSettle();

        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectNoErrorMessage(tester, 'Title is needed');
        expectNoErrorMessage(tester, 'Category needs to be selected');
        expectNoErrorMessage(tester, 'Priority needs to be selected');
        expectNoErrorMessage(tester, 'End date needs to be after start date');

        final captured = verify(() => mockGoalService.updateGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.id, existingGoal.id);
        expect(captured.progress.isAccomplished, isTrue);
        expect(captured.progress.startDate, isNull);
        expect(captured.progress.endDate, isNull);
      },
    );

    testWidgets(
      'When all fields are cleared, Save shows three error messages and does not update the goal',
      (tester) async {
        final viewModel = await setupExistingGoalViewModel(tester);

        await enterTitle(tester, '');
        final formState = tester.state<GoalFormState>(find.byType(GoalForm));
        formState.selectedCategory = null;
        formState.selectedProgress.priority = null;
        await tester.pumpAndSettle();

        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectErrorMessage(tester, 'Title is needed');
        expectErrorMessage(tester, 'Category needs to be selected');
        expectErrorMessage(tester, 'Priority needs to be selected');
        verifyNever(() => mockGoalService.updateGoal(any<Goal>()));
      },
    );

    testWidgets(
      'When title and category are filled but priority is missing, Save shows a priority error and does not update',
      (tester) async {
        final viewModel = await setupExistingGoalViewModel(tester);

        await enterTitle(tester, 'Titre conservé');
        await selectCategory(tester, Category.spiritualityReligion);
        final formState = tester.state<GoalFormState>(find.byType(GoalForm));
        formState.selectedProgress.priority = null;
        await tester.pumpAndSettle();

        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectNoErrorMessage(tester, 'Title is needed');
        expectNoErrorMessage(tester, 'Category needs to be selected');
        expectErrorMessage(tester, 'Priority needs to be selected');
        verifyNever(() => mockGoalService.updateGoal(any<Goal>()));
      },
    );

    testWidgets(
      'After displaying errors, filling all fields correctly and saving clears errors and updates the goal',
      (tester) async {
        final viewModel = await setupExistingGoalViewModel(tester);

        // Generate errors
        await enterTitle(tester, '');
        final formState = tester.state<GoalFormState>(find.byType(GoalForm));
        formState.selectedCategory = null;
        formState.selectedProgress.priority = null;
        await tester.pumpAndSettle();
        await tapConfirmButton(tester);
        await tester.pumpAndSettle();
        expectErrorMessage(tester, 'Title is needed');

        // Fill correctly
        await enterTitle(tester, 'But corrigé');
        await selectCategory(tester, Category.personalGrowth);
        await selectPriority(tester, Priority.high);
        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectNoErrorMessage(tester, 'Title is needed');
        expectNoErrorMessage(tester, 'Category needs to be selected');
        expectNoErrorMessage(tester, 'Priority needs to be selected');
        verify(() => mockGoalService.updateGoal(any<Goal>())).called(1);
        final captured = verify(() => mockGoalService.updateGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.id, existingGoal.id);
        expect(captured.title, 'But corrigé');
      },
    );

    testWidgets(
      'When end date is before start date, Save shows a date error and does not update the goal',
      (tester) async {
        final viewModel = await setupExistingGoalViewModel(tester);

        await enterTitle(tester, 'Date invalide');
        await selectCategory(tester, Category.other);
        await selectPriority(tester, Priority.medium);

        await toggleDateSwitch(tester, 'Start date', turnOn: true);
        await toggleDateSwitch(tester, 'End date', turnOn: true);

        final formState = tester.state<GoalFormState>(find.byType(GoalForm));
        final now = DateTime.now();
        formState.selectedProgress.startDate = now.add(Duration(days: 1));
        formState.selectedProgress.endDate = now;
        await tester.pumpAndSettle();

        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        expectErrorMessage(tester, 'End date needs to be after start date');
        verifyNever(() => mockGoalService.updateGoal(any<Goal>()));
      },
    );

    testWidgets(
      'Deactivating an existing start date toggle sets startDate to null when saving',
      (tester) async {
        final viewModel = await setupExistingGoalViewModel(tester);

        expect(viewModel.goal?.progress.startDate, isNotNull);
        expect(viewModel.goal?.progress.endDate, isNotNull);

        await toggleDateSwitch(tester, 'Start date', turnOn: false);
        await tester.pumpAndSettle();

        await enterTitle(tester, 'Nouveau titre avec date supprimée');
        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        final captured = verify(() => mockGoalService.updateGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.progress.startDate, isNull);
        expect(captured.progress.endDate, existingGoal.progress.endDate);
      },
    );

    testWidgets(
      'Deactivating an existing end date toggle sets endDate to null when saving',
      (tester) async {
        final viewModel = await setupExistingGoalViewModel(tester);

        await toggleDateSwitch(tester, 'End date', turnOn: false);
        await tester.pumpAndSettle();

        await enterTitle(tester, 'Nouveau titre sans fin');
        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        final captured = verify(() => mockGoalService.updateGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.progress.endDate, isNull);
        expect(captured.progress.startDate, existingGoal.progress.startDate);
      },
    );

    testWidgets(
      'Deactivating both existing date toggles sets both dates to null when saving',
      (tester) async {
        final viewModel = await setupExistingGoalViewModel(tester);

        await toggleDateSwitch(tester, 'Start date', turnOn: false);
        await toggleDateSwitch(tester, 'End date', turnOn: false);
        await tester.pumpAndSettle();

        await enterTitle(tester, 'Titre sans dates');
        await tapConfirmButton(tester);
        await tester.pumpAndSettle();

        final captured = verify(() => mockGoalService.updateGoal(captureAny()))
            .captured
            .single as Goal;
        expect(captured.progress.startDate, isNull);
        expect(captured.progress.endDate, isNull);
      },
    );
  });
}
