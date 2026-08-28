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
  const GoalView({Key? key, this.goalId}) : super(key: key);

  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

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

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => GoalViewModel(goalId: arg.goalId),
      onViewModelReady: (viewModel) =>
          {viewModel as GoalViewModel, viewModel.loadGoal()},
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
              _goalFormContainer(viewModel as GoalViewModel),
              _visionBoardContainer(),
              _tasksHandlerContainer(arg.goalId),
            ],
          ),
        );
      },
    );
  }
}

ViewModelBuilder<TaskViewModel> _tasksHandlerContainer(String? goalId) {
  return ViewModelBuilder.reactive(
    viewModelBuilder: () => TaskViewModel(goalId: goalId),
    builder: (context, visionBoardVM, child) =>
        TaskWidget(viewModel: visionBoardVM),
  );
}

ViewModelBuilder<VisionBoardViewModel> _visionBoardContainer() {
  return ViewModelBuilder.reactive(
    viewModelBuilder: () => VisionBoardViewModel(),
    builder: (context, visionBoardVM, child) =>
        VisionBoardWidget(viewModel: visionBoardVM),
  );
}

Container _goalFormContainer(GoalViewModel viewModel) {
  return Container(
    margin: EdgeInsets.all(16.0),
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
