import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:selfsight/presentation/view/daily_tasks/daily_tasks_viewmodel.dart';
import 'package:stacked/stacked.dart';
import 'package:selfsight/domain/entities/task/task.dart';
import 'package:selfsight/presentation/app/app.router.dart';
import 'package:selfsight/presentation/view/goal/task/task_helpers.dart';
import 'package:selfsight/presentation/view/templates.dart';

void showDailyTasksSheet(BuildContext context, String goalId,
    [VoidCallback? onDismissed]) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DailyTasksSheet(goalId: goalId),
  ).whenComplete(() {
    if (onDismissed != null) onDismissed();
  });
}

class DailyTasksSheet extends StatelessWidget {
  final String goalId;
  const DailyTasksSheet({required this.goalId, super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<DailyTasksViewModel>.reactive(
      viewModelBuilder: () => DailyTasksViewModel(goalId: goalId),
      onViewModelReady: (viewModel) => viewModel.load(),
      builder: (context, viewModel, child) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: viewModel.isBusy || viewModel.goal == null
                  ? const Center(child: CircularProgressIndicator())
                  : content(context, viewModel, scrollController),
            );
          },
        );
      },
    );
  }

  Widget content(BuildContext context, DailyTasksViewModel viewModel,
      ScrollController scrollController) {
    final goal = viewModel.goal!;

    return Column(
      children: [
        const SizedBox(height: 8),
        dragHandle(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: header(context, goal.title, goal.id),
        ),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              visionBoardPreview(viewModel.visionBoardSnapshotPath, context),
              const SizedBox(height: 20),
              smallTitleInterface("Today's tasks"),
              const SizedBox(height: 8),
              incompleteTaskList(viewModel),
              const SizedBox(height: 8),
              completeTaskList(context, viewModel)
            ],
          ),
        ),
      ],
    );
  }

  Widget dragHandle() {
    return Container(
      width: 60,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Row header(BuildContext context, String title, String goalId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: subtitleInterface(title)),
        TextButton.icon(
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: message("Edit"),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed(
              Routes.goalView,
              arguments: GoalViewArguments(goalId: goalId),
            );
          },
        ),
      ],
    );
  }

  Widget incompleteTaskList(DailyTasksViewModel viewModel) {
    if (viewModel.incompleteTasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: message("No tasks for today")),
      );
    }

    return Column(
      children: viewModel.incompleteTasks
          .map((task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: taskRow(viewModel, task),
              ))
          .toList(),
    );
  }

  Widget completeTaskList(BuildContext context, DailyTasksViewModel viewModel) {
    if (viewModel.incompleteTasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(child: message("No tasks for today")),
      );
    }

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  viewModel.isCompleteTaskListExpanded =
                      !viewModel.isCompleteTaskListExpanded;
                });
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    smallTitleInterface(
                      "Tasks completed for today or this week (${viewModel.completedTasks.length})",
                    ),
                    Icon(
                      viewModel.isCompleteTaskListExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                    ),
                  ],
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: viewModel.completedTasks
                    .map((task) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: taskRow(viewModel, task),
                        ))
                    .toList(),
              ),
              crossFadeState: viewModel.isCompleteTaskListExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        );
      },
    );
  }

  Widget taskRow(DailyTasksViewModel viewModel, Task task) {
    final target = task.frequency.time ?? 1;
    final progress = viewModel.progressFor(task);
    final isDone = viewModel.isCompleted(task);

    return Card(
      child: ListTile(
        title: Text(
          task.name,
          style: GoogleFonts.poppins(
            fontSize: 13,
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: subMessage(frequencySummary(task.frequency)),
        trailing: progressStepper(viewModel, task, progress, target),
      ),
    );
  }

  Widget progressStepper(
      DailyTasksViewModel viewModel, Task task, int progress, int target) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed:
              progress > 0 ? () => viewModel.adjustProgress(task, -1) : null,
        ),
        message('$progress/$target'),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: progress < target
              ? () => viewModel.adjustProgress(task, 1)
              : null,
        ),
      ],
    );
  }

  Widget visionBoardPreview(String? path, BuildContext context) {
    return ClipRRect(
      child: SizedBox(
        height: MediaQuery.of(context).size.width,
        width: MediaQuery.of(context).size.width,
        child: path != null
            ? Image.file(File(path), fit: BoxFit.contain)
            : Container(
                color: Colors.grey[200],
                child: Center(child: message("No vision board yet")),
              ),
      ),
    );
  }
}
