import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:selfsight/domain/entities/task/frequency.dart';
import 'package:selfsight/domain/entities/task/task.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/presentation/view/goal/task/task_form.dart';
import 'package:selfsight/presentation/view/goal/task/task_helpers.dart';
import 'package:selfsight/presentation/view/goal/task/task_viewmodel.dart';
import 'package:selfsight/presentation/view/goal/task/task_widget.dart';
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
    when(() => mockTaskService.saveTask(any())).thenAnswer((_) async {});
    when(() => mockTaskService.updateTask(any())).thenAnswer((_) async {});
    when(() => mockTaskService.deleteTask(any())).thenAnswer((_) async {});
  });

  tearDown(() {
    locator.reset();
  });

  // ==================== Helpers ====================
  Widget buildTaskWidget(TaskViewModel viewModel) {
    return MaterialApp(
      home: Scaffold(
        body: ListenableBuilder(
          listenable: viewModel,
          builder: (context, _) => TaskWidget(viewModel: viewModel),
        ),
      ),
    );
  }

  Future<void> openAddForm(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.add_circle_outline));
    await tester.pumpAndSettle();
  }

  Future<void> openEditForm(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
  }

  Future<void> enterName(WidgetTester tester, String name) async {
    await tester.enterText(find.byType(TextFormField).at(0), name);
    await tester.pumpAndSettle();
  }

  Future<void> selectAmount(WidgetTester tester, Amount amount) async {
    await tester.tap(find.byType(DropdownButtonFormField<Amount>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(capitalize(amount.name)).last);
    await tester.pumpAndSettle();
  }

  Future<void> enterValue(WidgetTester tester, String value) async {
    await tester.enterText(find.byType(TextFormField).at(1), value);
    await tester.pumpAndSettle();
  }

  Future<void> selectUnit(WidgetTester tester, Unit unit) async {
    await tester.tap(find.byType(DropdownButtonFormField<Unit>));
    await tester.pumpAndSettle();
    await tester.tap(find.text(capitalize(unit.name)).last);
    await tester.pumpAndSettle();
  }

  Future<void> toggleDay(WidgetTester tester, Day day) async {
    await tester.tap(find.widgetWithText(FilterChip, capitalize(day.name)));
    await tester.pumpAndSettle();
  }

  Future<void> tapConfirmButton(WidgetTester tester) async {
    final addButton = find.widgetWithText(ElevatedButton, 'Add');
    if (addButton.evaluate().isNotEmpty) {
      await tester.tap(addButton);
    } else {
      await tester.tap(find.widgetWithText(ElevatedButton, 'Save'));
    }
    await tester.pumpAndSettle();
  }

  void expectErrorMessage(String text) =>
      expect(find.text(text), findsOneWidget);
  void expectNoErrorMessage(String text) =>
      expect(find.text(text), findsNothing);

  const errNom = 'Task name is needed';
  const errAmount = 'Type of amount needs to be selected';
  const errValeur =
      'Value needs to be set and valid with a number without decimals';
  const errUnite = 'Unit needs to be selected';
  const errJours = 'Days need to be selected';

  // ==================== NEW TASK — goal not yet saved ====================

  group('New task - goal not yet saved (goalId == null)', () {
    testWidgets(
      '1.1 Filling name, amount (day), value, unit and days adds the task to the list and closes the form',
      (tester) async {
        // Arrange
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await openAddForm(tester);

        // Act
        await enterName(tester, "Boire de l'eau");
        await enterValue(tester, '8');
        await selectAmount(tester, Amount.day);
        await selectUnit(tester, Unit.count);
        await toggleDay(tester, Day.monday);
        await tapConfirmButton(tester);

        // Assert
        Frequency frequency = Frequency(
          amount: Amount.day,
          unit: Unit.count,
          days: [Day.monday],
          time: 8,
        );
        expect(find.text("Boire de l'eau"), findsOneWidget);
        expect(find.text(frequencySummary(frequency)), findsOneWidget);
        expect(find.byType(TaskFormSheet), findsNothing);
        verifyNever(() => mockTaskService.saveTask(any()));
      },
    );

    testWidgets(
      '1.2 Filling name, amount (week), value, unit and days adds the task to the list and closes the form',
      (tester) async {
        // Arrange
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await openAddForm(tester);

        // Act
        await enterName(tester, "Boire de l'eau");
        await enterValue(tester, '8');
        await selectAmount(tester, Amount.week);
        await selectUnit(tester, Unit.count);
        await tapConfirmButton(tester);

        // Assert
        Frequency frequency = Frequency(
          amount: Amount.week,
          unit: Unit.count,
          time: 8,
        );
        expect(find.text("Boire de l'eau"), findsOneWidget);
        expect(find.text(frequencySummary(frequency)), findsOneWidget);
        expect(find.byType(TaskFormSheet), findsNothing);
        verifyNever(() => mockTaskService.saveTask(any()));
      },
    );

    testWidgets(
      '2. Submitting the form empty shows three error messages and does not add a task',
      (tester) async {
        // Arrange
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));

        // Act
        await openAddForm(tester);
        await tapConfirmButton(tester);

// Assert
        expectErrorMessage(errNom);
        expectErrorMessage(errAmount);
        expectErrorMessage(errValeur);
        expectErrorMessage(errUnite);
        expectNoErrorMessage(errJours);
        expect(viewModel.tasks, isEmpty);
        verifyNever(() => mockTaskService.saveTask(any()));
      },
    );

    testWidgets(
      '3.1 (Amount: week) Submitting the form almost empty shows error messages and does not add a task',
      (tester) async {
        // Arrange
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));

        // Act
        await openAddForm(tester);
        await selectAmount(tester, Amount.week);
        await tapConfirmButton(tester);

        // Assert
        expectErrorMessage(errNom);
        expectNoErrorMessage(errAmount);
        expectErrorMessage(errValeur);
        expectErrorMessage(errUnite);
        expectNoErrorMessage(errJours);
        expect(viewModel.tasks, isEmpty);
        verifyNever(() => mockTaskService.saveTask(any()));
      },
    );

    testWidgets(
      '3.2 (Amount: day) Submitting the form almost empty shows error messages and does not add a task',
      (tester) async {
        // Arrange
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));

        // Act
        await openAddForm(tester);
        await selectAmount(tester, Amount.day);
        await tapConfirmButton(tester);

        // Assert
        expectErrorMessage(errNom);
        expectNoErrorMessage(errAmount);
        expectErrorMessage(errValeur);
        expectErrorMessage(errUnite);
        expectErrorMessage(errJours);
        expect(viewModel.tasks, isEmpty);
        verifyNever(() => mockTaskService.saveTask(any()));
      },
    );

    testWidgets(
      '4. After the errors are shown, filling everything correctly adds the task and clears the errors',
      (tester) async {
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await openAddForm(tester);

        await tapConfirmButton(tester);
        expectErrorMessage(errNom);
        expectErrorMessage(errAmount);
        expectErrorMessage(errValeur);
        expectErrorMessage(errUnite);
        expectNoErrorMessage(errJours);

        await enterName(tester, 'Marcher');
        await selectAmount(tester, Amount.day);
        await enterValue(tester, '30');
        await selectUnit(tester, Unit.minute);
        await toggleDay(tester, Day.tuesday);
        await tapConfirmButton(tester);

        expectNoErrorMessage(errNom);
        expectNoErrorMessage(errAmount);
        expectNoErrorMessage(errValeur);
        expectNoErrorMessage(errUnite);
        expectNoErrorMessage(errJours);
        expect(find.text('Marcher'), findsOneWidget);
        expect(viewModel.tasks.length, 1);
        verifyNever(() => mockTaskService.saveTask(any()));
      },
    );

    testWidgets(
      '5.1 An invalid decimal value shows only the value error',
      (tester) async {
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await openAddForm(tester);

        await enterName(tester, 'Yoga');
        await selectAmount(tester, Amount.day);
        await enterValue(tester, '12.43');
        await selectUnit(tester, Unit.minute);
        await toggleDay(tester, Day.wednesday);
        await tapConfirmButton(tester);

        expectErrorMessage(errValeur);
        expectNoErrorMessage(errNom);
        expectNoErrorMessage(errUnite);
        expectNoErrorMessage(errJours);
        expect(viewModel.tasks, isEmpty);
      },
    );

    testWidgets(
      '5.2 A value containing letters shows only the value error',
      (tester) async {
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await openAddForm(tester);

        await enterName(tester, 'Yoga');
        await selectAmount(tester, Amount.day);
        await enterValue(tester, '1dd2');
        await selectUnit(tester, Unit.minute);
        await toggleDay(tester, Day.wednesday);
        await tapConfirmButton(tester);

        expectErrorMessage(errValeur);
        expect(viewModel.tasks, isEmpty);
      },
    );
  });

  // ==================== EDIT TASK — goal not yet saved ====================

  group('Edit task - goal not yet saved (goalId == null)', () {
    testWidgets(
      '1. Clearing name, value and unchecking all days does not modify the task',
      (tester) async {
        final viewModel = TaskViewModel(goalId: null);
        await viewModel.addTask(
          'Tâche originale',
          Frequency(
              unit: Unit.minute,
              amount: Amount.day,
              time: 15,
              days: [Day.monday]),
        );
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await tester.pumpAndSettle();

        await openEditForm(tester);
        await enterName(tester, '');
        await enterValue(tester, '');
        await toggleDay(
            tester, Day.monday); // décoche le seul jour pré-sélectionné
        await tapConfirmButton(tester);

        expectErrorMessage(errNom);
        expect(viewModel.tasks.first.name, 'Tâche originale');
        verifyNever(() => mockTaskService.updateTask(any()));
      },
    );

    testWidgets(
      '2. Modifying all fields correctly updates the task successfully',
      (tester) async {
        final viewModel = TaskViewModel(goalId: null);
        await viewModel.addTask(
          'Ancien nom',
          Frequency(
              unit: Unit.minute,
              amount: Amount.day,
              time: 15,
              days: [Day.monday]),
        );
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await tester.pumpAndSettle();

        await openEditForm(tester);
        await enterName(tester, 'Nouveau nom');
        await enterValue(tester, '45');
        await selectAmount(tester, Amount.day);
        await selectUnit(tester, Unit.hour);
        await toggleDay(tester, Day.monday);
        await toggleDay(tester, Day.friday);
        await tapConfirmButton(tester);

        expect(find.text('Nouveau nom'), findsOneWidget);
        expect(
            find.text(frequencySummary(Frequency(
                unit: Unit.hour,
                amount: Amount.day,
                time: 45,
                days: [Day.friday]))),
            findsOneWidget);
        verifyNever(() => mockTaskService.updateTask(any()));
      },
    );
  });

  // ==================== goal already saved ====================

  group('New / edit / delete task - goal already saved (goalId != null)', () {
    const goalId = 'goal_456';

    testWidgets('Adding a valid task persists it through saveTask',
        (tester) async {
      final viewModel = TaskViewModel(goalId: goalId);
      await tester.pumpWidget(buildTaskWidget(viewModel));
      await openAddForm(tester);

      await enterName(tester, 'Lire');
      await enterValue(tester, '20');
      await selectAmount(tester, Amount.day);
      await selectUnit(tester, Unit.minute);
      await toggleDay(tester, Day.sunday);
      await tapConfirmButton(tester);

      expect(find.text('Lire'), findsOneWidget);

      verify(() => mockTaskService.saveTask(any())).called(1);
    });

    testWidgets('Editing a task persists the change through updateTask',
        (tester) async {
      final viewModel = TaskViewModel(goalId: goalId);
      await viewModel.addTask(
        'Ancien nom',
        Frequency(
            unit: Unit.minute,
            amount: Amount.day,
            time: 15,
            days: [Day.monday]),
      );
      await tester.pumpWidget(buildTaskWidget(viewModel));
      await tester.pumpAndSettle();

      await openEditForm(tester);
      await enterName(tester, 'Nouveau nom');
      await enterValue(tester, '20');
      await selectAmount(tester, Amount.day);
      await selectUnit(tester, Unit.minute);
      await toggleDay(tester, Day.sunday);
      await tapConfirmButton(tester);

      expect(find.text('Nouveau nom'), findsOneWidget);
      verify(() => mockTaskService.updateTask(any())).called(1);
    });

    testWidgets('Deleting a task persists the deletion through deleteTask',
        (tester) async {
      final viewModel = TaskViewModel(goalId: goalId);
      await viewModel.addTask(
        'À supprimer',
        Frequency(unit: Unit.minute, time: 15, days: [Day.monday]),
      );
      await tester.pumpWidget(buildTaskWidget(viewModel));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Confirm'));
      await tester.pumpAndSettle();

      expect(viewModel.tasks, isEmpty);
      verify(() => mockTaskService.deleteTask(any())).called(1);
    });
  });
}
