import 'package:flutter/material.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:selfsight/presentation/app/app.dart';
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/view/goal/goal_form.dart';
import 'package:selfsight/presentation/view/goal/goal_viewmodel.dart';
import 'package:selfsight/presentation/view/templates.dart';
import 'package:stacked/stacked.dart';

class GoalView extends StatefulWidget {
  final String goalId;
  const GoalView({
    Key? key,
    required this.goalId,
  }) : super(key: key);

  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView> {
  List<VisionBoardItem> list = [];

  @override
  Widget build(BuildContext context) {
    final arg = ModalRoute.of(context)?.settings.arguments as GoalViewArguments;

    return ViewModelBuilder.reactive(
      viewModelBuilder: () => GoalViewModel(goalId: arg.goalId),
      onViewModelReady: (viewModel) {
        viewModel as GoalViewModel;
        viewModel.loadGoal();
      },
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: titleInterface(arg.goalId == null ? "New goal" : "Edit goal"),
        ),
        body: Container(
          margin: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0),
              Expanded(
                child: SingleChildScrollView(
                  child: GoalForm(viewModel: viewModel as GoalViewModel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
