import 'package:flutter/material.dart';
import 'package:selfsight/presentation/view/daily_tasks/daily_tasks_viewmodel.dart';
import 'package:selfsight/presentation/view/templates.dart';

Widget dateNavigator(BuildContext context, DailyTasksViewModel viewModel) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      IconButton(
        icon: const Icon(Icons.chevron_left),
        onPressed: viewModel.canGoToPreviousDate
            ? () => viewModel.goToPreviousDate()
            : null,
      ),
      TextButton(
        onPressed: () => _pickDate(context, viewModel),
        child: message(_formatDate(viewModel.selectedDate)),
      ),
      IconButton(
        icon: const Icon(Icons.chevron_right),
        onPressed:
            viewModel.canGoToNextDate ? () => viewModel.goToNextDate() : null,
      ),
    ],
  );
}

Future<void> _pickDate(
    BuildContext context, DailyTasksViewModel viewModel) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: viewModel.selectedDate,
    firstDate: viewModel.startDateBound ?? DateTime(2000),
    lastDate: viewModel.todayBound,
  );
  if (picked != null) {
    viewModel.goToDate(picked);
  }
}

String _formatDate(DateTime date) {
  final today = DateTime.now();
  final isToday = date.year == today.year &&
      date.month == today.month &&
      date.day == today.day;
  if (isToday) return "Today";
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return "${months[date.month - 1]} ${date.day}, ${date.year}";
}
