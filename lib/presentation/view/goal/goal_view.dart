import 'package:flutter/material.dart';
import 'package:image_collage_widget/utils/collage_type.dart';
import 'package:selfsight/presentation/view/goal/goal_viewmodel.dart';
import 'package:selfsight/presentation/view/goal/goal_form.dart';
import 'package:selfsight/presentation/view/goal/vision_board.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

class GoalView extends StatefulWidget {
  const GoalView({super.key});

  @override
  State<GoalView> createState() => _GoalViewState();
}

class _GoalViewState extends State<GoalView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => GoalViewModel(),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            "New goal",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: Container(
          margin: EdgeInsets.all(16.0), // Space around all edges
          child: Column(
            children: [
              Expanded(
                flex: 3, // 30%
                child: VisionBoard(),
              ),
              SizedBox(height: 20.0), // Space BETWEEN the widgets
              Expanded(
                flex: 7, // 70%
                child: GoalForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
