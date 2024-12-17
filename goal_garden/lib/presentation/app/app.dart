import 'package:flutter/material.dart';
import 'package:goal_garden/presentation/view/home/home_view.dart';
import 'package:goal_garden/presentation/view/main_goal/main_goal_view.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:stacked/stacked_annotations.dart';

@StackedApp(
  routes: [
    MaterialRoute(page: HomeView, initial: true),
    MaterialRoute(page: MainGoalView),
  ],
  dependencies: [
    LazySingleton(classType: NavigationService),
  ],
)
class AppSetup {}
