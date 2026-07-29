import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';
import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/presentation/view/goal/goal_view.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:stacked_services/stacked_services.dart';

@GenerateMocks([GoalService, NavigationService])
import 'mocks/goal_view_test.mocks.dart';

void main() {
  late MockGoalService mockGoalService;
  late MockNavigationService mockNavigationService;

  setUp(() {
    mockGoalService = MockGoalService();
    mockNavigationService = MockNavigationService();

    // Register mocks in locator (override existing)
    locator.registerSingleton<GoalService>(mockGoalService);
    locator.registerSingleton<NavigationService>(mockNavigationService);
  });

  tearDown(() {
    locator.reset();
  });

  Widget buildGoalView({String? goalId}) {
    return MaterialApp(
      onGenerateRoute: (settings) {
        // Simulate route with arguments
        if (settings.name == Routes.goalView) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => GoalView(goalId: goalId ?? ''),
          );
        }
        return null;
      },
      routes: {
        Routes.goalView: (context) => GoalView(goalId: goalId ?? ''),
      },
    );
  }

  group('GoalView', () {
    testWidgets(
        'Si on veut crée un nouveau objectif (si goalId est vide ou null), le titre de l"interface est "New goal"',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: Routes.goalView,
                        arguments: GoalViewArguments(goalId: null),
                      ),
                      builder: (_) => const GoalView(goalId: ''),
                    ),
                  );
                },
                child: const Text('Go to Goal'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go to Goal'));
      await tester.pumpAndSettle();

      expect(find.text('New goal'), findsOneWidget);
      expect(find.text('Edit goal'), findsNothing);
    });

    testWidgets(
        'Si on accéder à un objectif déjà sauvegardé (si goalId n"est pas vide ni null), le titre de l"interface est "Edit goal"',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: Routes.goalView,
                        arguments: GoalViewArguments(goalId: '123'),
                      ),
                      builder: (_) => const GoalView(goalId: '123'),
                    ),
                  );
                },
                child: const Text('Go to Goal'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go to Goal'));
      await tester.pumpAndSettle();

      expect(find.text('Edit goal'), findsOneWidget);
      expect(find.text('New goal'), findsNothing);
    });

    testWidgets('onViewModelReady calls loadGoal', (tester) async {
      const goalId = '123';
      final expectedGoal = Goal(
        id: goalId,
        title: 'Test Goal',
        visionBoardPath: null,
        progress: Progress(isAccomplished: false),
        category: Category.healthFitness,
        tasks: [],
        createAt: DateTime.now().toIso8601String(),
      );
      when(mockGoalService.getGoalById(goalId))
          .thenAnswer((_) async => expectedGoal);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: const RouteSettings(
                        name: Routes.goalView,
                        arguments: GoalViewArguments(goalId: goalId),
                      ),
                      builder: (_) => const GoalView(goalId: goalId),
                    ),
                  );
                },
                child: const Text('Go to Goal'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Go to Goal'));
      await tester.pumpAndSettle();

      verify(mockGoalService.getGoalById(goalId)).called(1);
    });
  });
}
