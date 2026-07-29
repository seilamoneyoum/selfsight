import 'package:flutter/material.dart';
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/view/goal/goal_form.dart';
import 'package:selfsight/presentation/view/goal/goal_viewmodel.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_viewmodel.dart';
import 'package:selfsight/presentation/view/goal/vision_board/vision_board_widget.dart';
import 'package:selfsight/presentation/view/templates.dart';
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
            title:
                titleInterface(arg.goalId == null ? "New goal" : "Edit goal"),
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
            physics: const NeverScrollableScrollPhysics(), // ❌ disables swipe
            children: [
              goalFormContainer(viewModel as GoalViewModel),
              ViewModelBuilder.reactive(
                viewModelBuilder: () => VisionBoardViewModel(),
                builder: (context, visionBoardVM, child) => VisionBoardWidget(
                    viewModel: visionBoardVM as VisionBoardViewModel),
              ),
              const Center(child: Icon(Icons.directions_bike, size: 64)),
            ],
          ),
        );
      },
    );
  }
}

Container goalFormContainer(GoalViewModel viewModel) {
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
