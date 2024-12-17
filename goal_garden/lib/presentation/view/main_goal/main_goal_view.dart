import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainGoalView extends StatefulWidget {
  const MainGoalView({super.key});

  @override
  _MainGoalViewState createState() => _MainGoalViewState();
}

class _MainGoalViewState extends State<MainGoalView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Text("This is the goal page"),
    );
  }
}
