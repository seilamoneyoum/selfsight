import 'package:goal_garden/presentation/app/app.router.dart';
import 'package:goal_garden/presentation/app/app_setup.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();

  void addMainGoal() {
    _navigationService.navigateTo(Routes.mainGoalView);
  }

  void navigateToMainGoalView() {
    _navigationService.navigateTo(Routes.mainGoalView);
  }
}
