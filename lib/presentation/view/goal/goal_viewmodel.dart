import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:stacked/stacked.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:stacked_services/stacked_services.dart';

class GoalViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _goalService = locator<GoalService>();

  /// Ajouter un nouveau objectif
  /// - Sans tâches et vision board définis pour le moment [À modifier plus tard]
  Future<void> addGoal(
      String title, Category category, Progress progress) async {
    final newGoal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      visionBoardPath: null,
      progress: progress,
      category: category,
      tasks: [],
      createAt: DateTime.now().toIso8601String(),
    );

    await _goalService.saveGoal(newGoal);
  }

  // Navigation
  void navigateToHomeGoalView() {
    _navigationService.navigateTo(Routes.homeView);
  }

  void navigateToVisionBoardView() {
    _navigationService.navigateTo(Routes.visionBoardView);
  }
}
