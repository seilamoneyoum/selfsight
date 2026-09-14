import 'package:selfsight/presentation/view/daily_tasks/daily_tasks_viewmodel.dart';

class DateNavigatorLogic {
  DailyTasksViewModel viewModel;

  DateNavigatorLogic({required this.viewModel});

  static DateTime _stripTime(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  DateTime _selectedDate = _stripTime(DateTime.now());
  DateTime get selectedDate => _selectedDate;

  DateTime get _todayDate => _stripTime(DateTime.now());

  DateTime? get startDateBound {
    final start = viewModel.goal?.progress.startDate;
    return start != null ? _stripTime(start) : null;
  }

  DateTime get todayBound => _todayDate;

  bool get canGoToPreviousDate =>
      startDateBound == null || _selectedDate.isAfter(startDateBound!);

  bool get canGoToNextDate => _selectedDate.isBefore(_todayDate);

  Future<void> goToPreviousDate() async {
    if (!canGoToPreviousDate) return;
    await _changeDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  Future<void> goToNextDate() async {
    if (!canGoToNextDate) return;
    await _changeDate(_selectedDate.add(const Duration(days: 1)));
  }

  Future<void> goToDate(DateTime date) async {
    DateTime clamped = _stripTime(date);
    final start = startDateBound;
    if (start != null && clamped.isBefore(start)) clamped = start;
    if (clamped.isAfter(_todayDate)) clamped = _todayDate;
    if (clamped == _selectedDate) return;
    await _changeDate(clamped);
  }

  Future<void> _changeDate(DateTime date) async {
    await viewModel.persistCurrentLists();
    _selectedDate = date;
    await viewModel.load();
  }
}
