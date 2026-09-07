import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:selfsight/services/vision_board_service.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _goalService = locator<GoalService>();
  final _visionBoardService = locator<VisionBoardService>();

  List<Goal> _goals = [];
  List<Goal> get goals => _goals;

  int get nbMainGoal => _goals.length;

  Map<String, String?> _snapshotPaths = {};
  String? snapshotPathFor(String goalId) => _snapshotPaths[goalId];

  /// Charger les objectifs et les rendre visibles à la page d'accueil
  Future<void> loadGoals() async {
    setBusy(true);
    _goals = await _goalService.getGoals();
    _goals.sort((a, b) => a.id.compareTo(b.id));

    final Map<String, String?> paths = {};
    for (final goal in _goals) {
      final board = await _visionBoardService.getVisionBoardByGoalId(goal.id);
      paths[goal.id] = board?.snapshotPath;
    }
    _snapshotPaths = paths;

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
