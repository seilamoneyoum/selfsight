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

  String? goalId;
  GoalViewModel({this.goalId});

  Goal? _goal;
  Goal? get goal => _goal;

  /// Charger l'objectif existant sur l'interface
  Future<void> loadGoal() async {
    if (goalId != null) {
      setBusy(true);
      _goal = await _goalService.getGoalById(goalId!);
      setBusy(false);
      notifyListeners();
    }
  }

  /// Ajouter un nouveau objectif
  /// - Sans tâches et vision board définis pour le moment [À modifier plus tard]
  Future<void> addGoal(
      String title, Category category, Progress progress) async {
    _goal = Goal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      visionBoardPath: null,
      progress: progress,
      category: category,
      tasks: [],
      createAt: DateTime.now().toIso8601String(),
    );

    await _goalService.saveGoal(_goal!);

    goalId = _goal?.id;

    notifyListeners();
  }

  /// Effacer l'objectif existant (et retourner à la page d'accueil)
  Future<void> deleteGoal() async {
    await _goalService.deleteGoal(goalId!);
    goalId = null;
    navigateToHomeGoalView();
  }

  /// Mise à jour d'un objectif existant
  Future<void> updateGoal(
      String title, Category category, Progress progress) async {
    _goal?.category = category;
    _goal?.progress = progress;
    _goal?.title = title;

    await _goalService.updateGoal(_goal!);
  }

  // Navigation
  Future<void> navigateToHomeGoalView() async {
    await _navigationService.navigateTo(Routes.homeView);
  }
}
