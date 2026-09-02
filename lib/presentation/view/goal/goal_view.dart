import 'package:flutter/material.dart';
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/view/goal/goal_form.dart';
import 'package:selfsight/presentation/view/goal/goal_viewmodel.dart';
import 'package:selfsight/presentation/view/goal/task/task_viewmodel.dart';
import 'package:selfsight/presentation/view/goal/task/task_widget.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_widget.dart';
import 'package:selfsight/presentation/view/templates.dart';
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

  GoalViewModel? _goalViewModel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _pageController = PageController();

    _tabController.addListener(() {
      final newIndex = _tabController.index;

      if (newIndex != 0 && _goalViewModel?.goalId == null) {
        _tabController.index = _pageController.page?.round() ?? 0;
        return;
      }
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

    return ViewModelBuilder<GoalViewModel>.reactive(
      viewModelBuilder: () => GoalViewModel(goalId: arg.goalId),
      onViewModelReady: (viewModel) {
        _goalViewModel = viewModel;
        viewModel.loadGoal();
      },
      builder: (context, viewModel, child) {
        bool isInEditingMode = viewModel.goalId != null;

        return Scaffold(
          appBar: AppBar(
            bottom: TabBar(
              controller: _tabController,
              tabs: [
                const Tab(text: "Goal"),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      message("Vision board"),
                      if (!isInEditingMode) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.lock_outline, size: 14),
                      ],
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      message("Tasks"),
                      if (!isInEditingMode) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.lock_outline, size: 14),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              if (_tabController.index != index) {
                _tabController.index = index;
              }
            },
            children: [
              _goalFormContainer(viewModel),
              isInEditingMode
                  ? _visionBoardContainer(viewModel.goalId!)
                  : _tabLockedPlaceholder(),
              isInEditingMode
                  ? _taskViewContainer(viewModel.goalId!)
                  : _tabLockedPlaceholder(),
            ],
          ),
        );
      },
    );
  }
}

ViewModelBuilder<TaskViewModel> _taskViewContainer(String goalId) {
  return ViewModelBuilder<TaskViewModel>.reactive(
    viewModelBuilder: () => TaskViewModel(goalId: goalId),
    onViewModelReady: (viewModel) => viewModel.loadTasks(),
    builder: (context, tasksVM, child) => TaskWidget(viewModel: tasksVM),
  );
}

ViewModelBuilder<VisionBoardViewModel> _visionBoardContainer(String goalId) {
  return ViewModelBuilder<VisionBoardViewModel>.reactive(
    viewModelBuilder: () => VisionBoardViewModel(goalId: goalId),
    onViewModelReady: (viewModel) => viewModel.loadVisionBoard(),
    builder: (context, visionBoardVM, child) =>
        VisionBoardWidget(viewModel: visionBoardVM),
  );
}

Widget _tabLockedPlaceholder() {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          message("Save your goal first to unlock this functionality"),
        ],
      ),
    ),
  );
}

Container _goalFormContainer(GoalViewModel viewModel) {
  return Container(
    margin: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20.0),
        Expanded(
          child: SingleChildScrollView(
            child: GoalForm(viewModel: viewModel),
          ),
        ),
      ],
    ),
  );
}
