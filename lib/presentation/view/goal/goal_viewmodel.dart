import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class GoalViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  int nbMainGoal = 1;

  void addMainGoal() {
    nbMainGoal++;
    //_navigationService.navigateTo(Routes.GoalView);
  }

  void navigateToHomeGoalView() {
    _navigationService.navigateTo(Routes.homeView);
  }

  void navigateToVisionBoardView() {
    _navigationService.navigateTo(Routes.visionBoardView);
  }
}
