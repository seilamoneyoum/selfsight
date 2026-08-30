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
  const errValeur =
      'Value needs to be set and valid with a number without decimals';
  const errUnite = 'Unit needs to be selected';
  const errJours = 'Days need to be selected';

  // ==================== NEW TASK — goal not yet saved ====================

  group('New task - goal not yet saved (goalId == null)', () {
    testWidgets(
      '1. Filling name, value, unit and days adds the task to the list and closes the form',
      (tester) async {
        // Arrange
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await openAddForm(tester);

        // Act
        await enterName(tester, "Boire de l'eau");
        await enterValue(tester, '8');
        await selectUnit(tester, Unit.count);
        await toggleDay(tester, Day.monday);
        await tapConfirmButton(tester);

        // Assert
        expect(find.text("Boire de l'eau"), findsOneWidget);
        expect(find.byType(TaskFormSheet), findsNothing);
        verifyNever(() => mockTaskService.saveTask(any()));
      },
    );

    testWidgets(
      '2. Submitting the form empty shows the 4 error messages and does not add a task',
      (tester) async {
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await openAddForm(tester);

        await tapConfirmButton(tester);

        expectErrorMessage(errNom);
        expectErrorMessage(errValeur);
        expectErrorMessage(errUnite);
        expectErrorMessage(errJours);
        expect(viewModel.tasks, isEmpty);
        verifyNever(() => mockTaskService.saveTask(any()));
      },
    );

    testWidgets(
      '2.1 After the 4 errors are shown, filling everything correctly adds the task and clears the errors',
      (tester) async {
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await openAddForm(tester);

        await tapConfirmButton(tester); // génère les 4 erreurs
        expectErrorMessage(errNom);

        await enterName(tester, 'Marcher');
        await enterValue(tester, '30');
        await selectUnit(tester, Unit.minutes);
        await toggleDay(tester, Day.tuesday);
        await tapConfirmButton(tester);

        expect(find.text('Marcher'), findsOneWidget);
        expect(viewModel.tasks.length, 1);
        verifyNever(() => mockTaskService.saveTask(any()));
      },
    );

    testWidgets(
      '3.1 An invalid decimal value shows only the value error',
      (tester) async {
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await openAddForm(tester);

        await enterName(tester, 'Yoga');
        await enterValue(tester, '12.43');
        await selectUnit(tester, Unit.minutes);
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
      '3.2 A value containing letters shows only the value error',
      (tester) async {
        final viewModel = TaskViewModel(goalId: null);
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await openAddForm(tester);

        await enterName(tester, 'Yoga');
        await enterValue(tester, '1dd2');
        await selectUnit(tester, Unit.minutes);
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
          Frequency(unit: Unit.minutes, time: 15, days: [Day.monday]),
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
          Frequency(unit: Unit.minutes, time: 15, days: [Day.monday]),
        );
        await tester.pumpWidget(buildTaskWidget(viewModel));
        await tester.pumpAndSettle();

        await openEditForm(tester);
        await enterName(tester, 'Nouveau nom');
        await enterValue(tester, '45');
        await selectUnit(tester, Unit.hours);
        await toggleDay(tester, Day.monday); // décoche
        await toggleDay(tester, Day.friday); // coche
        await tapConfirmButton(tester);

        expect(find.text('Nouveau nom'), findsOneWidget);
        expect(viewModel.tasks.first.name, 'Nouveau nom');
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
      await selectUnit(tester, Unit.minutes);
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
        Frequency(unit: Unit.minutes, time: 15, days: [Day.monday]),
      );
      await tester.pumpWidget(buildTaskWidget(viewModel));
      await tester.pumpAndSettle();

      await openEditForm(tester);
      await enterName(tester, 'Nouveau nom');
      await tapConfirmButton(tester);

      expect(find.text('Nouveau nom'), findsOneWidget);
      verify(() => mockTaskService.updateTask(any())).called(1);
    });

    testWidgets('Deleting a task persists the deletion through deleteTask',
        (tester) async {
      final viewModel = TaskViewModel(goalId: goalId);
      await viewModel.addTask(
        'À supprimer',
        Frequency(unit: Unit.minutes, time: 15, days: [Day.monday]),
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
