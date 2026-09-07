import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfsight/presentation/view/daily_tasks/daily_tasks_sheet.dart';
import 'package:selfsight/presentation/view/home/home_viewmodel.dart';
import 'package:selfsight/presentation/view/templates.dart';
import 'package:stacked/stacked.dart';
import 'package:selfsight/domain/entities/goal/category.dart';
import 'package:selfsight/domain/entities/goal/goal.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeViewModel>.reactive(
      viewModelBuilder: () => HomeViewModel(),
      onViewModelReady: (viewModel) => viewModel.loadGoals(),
      builder: (context, viewModel, child) => Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header(context),
              Expanded(
                child: viewModel.isBusy
                    ? const Center(child: CircularProgressIndicator())
                    : viewModel.goals.isEmpty
                        ? const Center(child: Text('No goals yet'))
                        : GridView.count(
                            crossAxisCount: 2,
                            padding: const EdgeInsets.all(8),
                            childAspectRatio: 0.8,
                            children: viewModel.goals.map((goal) {
                              return goalCard(context, goal, viewModel);
                            }).toList(),
                          ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await viewModel.navigateToMainGoalView();
            viewModel.loadGoals();
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget header(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            titleInterface("My Goals"),
            smallTitleInterface("  -  ${formattedDate(DateTime.now())}")
          ]),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget goalCard(BuildContext context, Goal goal, HomeViewModel viewModel) {
    final snapshotPath = viewModel.snapshotPathFor(goal.id);

    return GestureDetector(
      onTap: () => showDailyTasksSheet(context, goal.id, viewModel.loadGoals),
      child: Container(
        margin: const EdgeInsets.all(8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: visionBoardPreview(snapshotPath)),
            const SizedBox(height: 6),
            goalInfoLine1(goal),
            const SizedBox(height: 2),
            goalInfoLine2(goal),
          ],
        ),
      ),
    );
  }

  Widget visionBoardPreview(String? snapshotPath) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: snapshotPath != null
          ? Image.file(File(snapshotPath), fit: BoxFit.cover)
          : Container(
              color: Colors.grey[200],
              child: Center(
                child: Icon(Icons.image_outlined, color: Colors.grey[400]),
              ),
            ),
    );
  }

  Widget goalInfoLine1(Goal goal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(goal.category?.icon ?? Icons.category, size: 14),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            goal.title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget goalInfoLine2(Goal goal) {
    return Text(
      goal.progress.isAccomplished ? 'Completed' : 'In progress',
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(
        fontSize: 10,
        color: goal.progress.isAccomplished ? Colors.green : Colors.orange,
      ),
    );
  }
}
