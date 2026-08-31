import 'package:flutter/material.dart';
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/view/goal/goal_form.dart';
import 'package:selfsight/presentation/view/goal/goal_viewmodel.dart';
import 'package:selfsight/presentation/view/goal/task/task_viewmodel.dart';
import 'package:selfsight/presentation/view/goal/task/task_widget.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_widget.dart';
import 'package:stacked/stacked.dart';

class GoalView extends StatefulWidget {
  final String? goalId;
  const GoalView({super.key, this.goalId});

  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  // Créé une seule fois via le `??=` dans build(), pas nichée dans un
  // ViewModelBuilder par onglet : ça évite le problème d'ordre de
  // construction entre onglets frères, et permet à GoalForm d'y accéder
  // directement pour commiter les tâches en brouillon.
  TaskViewModel? _taskViewModel;
  bool _hasLoadedTasks = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();

    _tabController.addListener(() {
      final newIndex = _tabController.index;
      if (_pageController.page?.round() != newIndex) {
        _pageController.animateToPage(
          newIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments as GoalViewArguments;

    _taskViewModel ??= TaskViewModel(goalId: arg.goalId);
    if (!_hasLoadedTasks) {
      _hasLoadedTasks = true;
      _taskViewModel!.loadTasks();
    }

    return ViewModelBuilder<GoalViewModel>.reactive(
      viewModelBuilder: () => GoalViewModel(goalId: arg.goalId),
      onViewModelReady: (viewModel) => viewModel.loadGoal(),
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "Goal"),
                Tab(text: "Vision board"),
                Tab(text: "Tasks"),
              ],
            ),
          ),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _goalFormContainer(viewModel, _taskViewModel!),
              _visionBoardContainer(),
              ListenableBuilder(
                listenable: _taskViewModel!,
                builder: (context, _) => TaskWidget(viewModel: _taskViewModel!),
              ),
            ],
          ),
        );
      },
    );
  }
}

ViewModelBuilder<VisionBoardViewModel> _visionBoardContainer() {
  return ViewModelBuilder.reactive(
    viewModelBuilder: () => VisionBoardViewModel(),
    builder: (context, visionBoardVM, child) =>
        VisionBoardWidget(viewModel: visionBoardVM),
  );
}

Container _goalFormContainer(
    GoalViewModel viewModel, TaskViewModel taskViewModel) {
  return Container(
    margin: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0),
        Expanded(
          child: SingleChildScrollView(
            child: GoalForm(viewModel: viewModel, taskViewModel: taskViewModel),
          ),
        ),
      ],
    ),
  );
}
