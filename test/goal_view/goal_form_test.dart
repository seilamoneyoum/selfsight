import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/presentation/view/goal/goal_form.dart';
import 'package:selfsight/presentation/view/goal/goal_viewmodel.dart';

@GenerateMocks([GoalViewModel])
import 'mocks/goal_form_test.mocks.dart';

void main() {
  late MockGoalViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockGoalViewModel();
    when(mockViewModel.notifyListeners()).thenReturn(null);
  });

  Widget buildForm() {
    return MaterialApp(
      home: Scaffold(
        body: GoalForm(viewModel: mockViewModel),
      ),
    );
  }

  group('GoalForm', () {
    testWidgets('Tous les champs de formulaire doivent s"afficher',
        (tester) async {
      await tester.pumpWidget(buildForm());

      expect(find.byType(TextFormField), findsOneWidget);

      expect(find.text('Category'), findsOneWidget);

      expect(find.text('Start date'), findsOneWidget);
      expect(find.byType(CupertinoSwitch), findsNWidgets(2)); // two switches

      expect(find.text('End date'), findsOneWidget);

      expect(find.text('Is accomplished?'), findsOneWidget);

      expect(find.text('Priority'), findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Confirm'), findsOneWidget);

      expect(find.widgetWithText(ElevatedButton, 'Set Vision Board'),
          findsOneWidget);
    });

    testWidgets(
        'Lorsque le bouton confirm est cliqué, mais que les champs à remplir obligatoirement sont vides, les messages d"erreur doivent s"apparaître et la méthode addGoal ne doit pas être appelée.',
        (tester) async {
      await tester.pumpWidget(buildForm());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
      await tester.pump();

      expect(find.text('Title is needed'), findsOneWidget);
      expect(find.text('Category needs to be selected'), findsOneWidget);
      expect(find.text('Priority needs to be selected'), findsOneWidget);

      verifyNever(mockViewModel.addGoal(any, any, any));
    });

    testWidgets(
        'Lorsque le bouton confirm est cliqué avec tous les champs obligatoires remplis, l"objectif est ajouté (la méthode addGoal est appelée)',
        (tester) async {
      when(mockViewModel.addGoal(any, any, any)).thenAnswer((_) async {});

      await tester.pumpWidget(buildForm());

      await tester.enterText(find.byType(TextFormField), 'My Goal');

      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Other').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Priority'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('High').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Confirm'));
      await tester.pump();

      verify(mockViewModel.addGoal('My Goal', Category.healthFitness, any))
          .called(1);
    });

    testWidgets('L"interaction avec le champ du début de date est fonctionnel',
        (tester) async {
      await tester.pumpWidget(buildForm());

      expect(find.byType(ElevatedButton), findsNWidgets(2));

      final switches =
          tester.widgetList<CupertinoSwitch>(find.byType(CupertinoSwitch));
      final startSwitch = switches.first;
      expect(startSwitch.value, false);

      await tester.tap(find.byType(CupertinoSwitch).first);
      await tester.pump();

      expect(find.byType(ElevatedButton), findsNWidgets(3));
      expect(find.text(DateTime.now().toString().substring(0, 10)),
          findsOneWidget);
    });

    testWidgets(
        'navigateToVisionBoardView est appelé lorsque le bouton Set Vision Board est cliqué',
        (tester) async {
      when(mockViewModel.navigateToVisionBoardView()).thenReturn(null);

      await tester.pumpWidget(buildForm());

      await tester.enterText(find.byType(TextFormField), 'Goal');
      await tester.tap(find.text('Category'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Health').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Priority'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('High').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Set Vision Board'));
      await tester.pump();

      verify(mockViewModel.navigateToVisionBoardView()).called(1);
    });
  });
}
