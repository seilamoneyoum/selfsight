import 'package:flutter/material.dart';
import 'package:goal_garden/presentation/view/goal/goal_viewmodel.dart';
import 'package:goal_garden/presentation/view/goal/goal_form.dart';
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
              fontSize: 24, // Change the font size
              fontWeight: FontWeight.bold, // Change the font weight
              color: Colors.black, // Change the text color
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 50),
          child: const GoalForm(),
        ),
      ),
    );
  }
}
