import 'package:flutter/material.dart';
import 'package:selfsight/domain/entities/vision_board/vision_board_item.dart';
import 'package:selfsight/presentation/view/goal/goal_form.dart';
import 'package:selfsight/presentation/view/goal/goal_viewmodel.dart';
import 'package:selfsight/presentation/view/general/title_interface.dart';
import 'package:stacked/stacked.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalView extends StatefulWidget {
  const GoalView({super.key});
  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView> {
  List<VisionBoardItem> list = [];

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => GoalViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: titleInterface("New goal"),
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
