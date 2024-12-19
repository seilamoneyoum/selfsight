import 'package:goal_garden/presentation/app/app.router.dart';
import 'package:goal_garden/presentation/app/app_setup.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class MainGoalViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  int nbMainGoal = 1;

  void addMainGoal() {
    nbMainGoal++;
    //_navigationService.navigateTo(Routes.mainGoalView);
  }

  void navigateToHomeGoalView() {
    _navigationService.navigateTo(Routes.homeView);
  }
}
