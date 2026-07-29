import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_widget.dart';
import 'package:selfsight/presentation/view/home/home_view.dart';
import 'package:selfsight/presentation/view/goal/goal_view.dart';
import 'package:stacked/stacked_annotations.dart';

@StackedApp(routes: [
  MaterialRoute(page: HomeView, initial: true),
  MaterialRoute(page: GoalView),
  MaterialRoute(page: VisionBoardView),
])
class AppSetup {}
