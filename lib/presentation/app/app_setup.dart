import 'package:selfsight/services/goal_service.dart';
import 'package:selfsight/services/task_service.dart';
import 'package:selfsight/services/vision_board_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;

class AppSetup {
  static Future<void> setupLocator() async {
    _registerServices();
    _registerUseCases();
  }

  static void _registerServices() {
    locator.registerLazySingleton(() => NavigationService());
    locator.registerLazySingleton(() => GoalService());
    locator.registerLazySingleton(() => TaskService());
    locator.registerLazySingleton(() => VisionBoardService());
  }

  static void _registerUseCases() {}
}
