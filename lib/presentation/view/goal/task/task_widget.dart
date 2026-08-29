import 'package:flutter/material.dart';
import 'package:selfsight/presentation/view/goal/task/task_form.dart';
import 'package:selfsight/presentation/view/goal/task/task_helpers.dart';
import 'package:selfsight/presentation/view/goal/task/task_viewmodel.dart';
import 'package:selfsight/presentation/view/templates.dart';

class TaskWidget extends StatefulWidget {
  final TaskViewModel viewModel;

  const TaskWidget({required this.viewModel, super.key});

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        header(context),
        const SizedBox(height: 12),
        Expanded(child: taskList()),
      ],
    );
  }

  // ======================== Sous-méthodes ====================================

  Row header(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        subtitleInterface("    " "Tasks"),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => _openTaskForm(context),
        ),
      ],
    );
  }

  Widget taskList() {
    if (widget.viewModel.isBusy) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.viewModel.tasks.isEmpty) {
      return Center(child: message("No tasks yet"));
    }

    return ListView.separated(
      itemCount: widget.viewModel.tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = widget.viewModel.tasks[index];
        return Card(
          child: ListTile(
            title: message(task.name),
            subtitle: subMessage(frequencySummary(task.frequency)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _openTaskForm(context, editId: task.id),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _confirmDelete(context, task.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openTaskForm(BuildContext context, {String? editId}) {
    if (editId != null) {
      widget.viewModel.startEditingTask(editId);
    } else {
      widget.viewModel.startAddingTask();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TaskFormSheet(viewModel: widget.viewModel),
    ).whenComplete(() => widget.viewModel.cancelEditing());
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: message('Confirm Action'),
        content: message(
            'Are you sure you want to delete this task? Once you delete this task, there is no way of retrieving it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: message('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              widget.viewModel.deleteTask(id);
            },
            child: message('Confirm'),
          ),
        ],
      ),
    );
  }
}
