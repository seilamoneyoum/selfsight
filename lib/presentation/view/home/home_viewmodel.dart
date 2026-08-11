// home_viewmodel.dart
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _goalService = locator<GoalService>();

  List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  int get nbMainGoal => _goals.length;

  /// Charger les objectifs et les rendre visibles à la page d'accueil
  Future<void> loadGoals() async {
    setBusy(true);
    _goals = await _goalService.getGoals();
    setBusy(false);
    notifyListeners();
  }

  /// Création d'un nouveau objectif
  Future<void> navigateToMainGoalView() async {
    // Ajoutez 'await' pour attendre la fermeture de la route
    await _navigationService.navigateTo(
      Routes.goalView,
      arguments: GoalViewArguments(goalId: null),
    );
    // Rechargez après le retour
    await loadGoals();
  }

  /// Accès au objectif existant
  Future<void> navigateToSpecificGoal(String goalId) async {
    await _navigationService.navigateTo(
      Routes.goalView,
      arguments: GoalViewArguments(goalId: goalId),
    );
    await loadGoals();
  }
}
