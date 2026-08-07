import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/app/app_setup.dart';
import 'package:stacked/stacked.dart';
import 'package:selfsight/services/goal_service.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:stacked_services/stacked_services.dart';

class TaskViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _goalService = locator<GoalService>();
}
