import 'package:selfsight/domain/entities/task/frequency.dart';
import 'package:selfsight/domain/entities/task/task.dart';

String capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

String dayLabel(Day day) {
  switch (day) {
    case Day.monday:
      return "Mon";
    case Day.tuesday:
      return "Tue";
    case Day.wednesday:
      return "Wed";
    case Day.thursday:
      return "Thu";
    case Day.friday:
      return "Fri";
    case Day.saturday:
      return "Sat";
    case Day.sunday:
      return "Sun";
  }
}

Day dayFromWeekday(int weekday) {
  return Day.values[weekday - 1];
}

String frequencySummary(Frequency frequency) {
  final List<String> parts = [];

  if (frequency.time != null &&
      frequency.unit != null &&
      frequency.amount != null) {
    if (frequency.unit == Unit.count) {
      parts.add("${frequency.time} times per ${frequency.amount!.name}");
    } else {
      parts.add(
          "${frequency.time} ${frequency.unit!.name} per ${frequency.amount!.name}");
    }
  }
  if (frequency.days != null && frequency.days!.isNotEmpty) {
    parts.add(frequency.days!.map(dayLabel).join(", "));
  }

  return parts.isEmpty ? "No schedule set" : parts.join(" · ");
}

String progressKeyFor(DateTime date, Amount amount) {
  if (amount == Amount.week) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceStart = date.difference(firstDayOfYear).inDays;
    final weekNumber =
        ((daysSinceStart + firstDayOfYear.weekday - 1) / 7).ceil();
    return '${date.year}-W${weekNumber.toString().padLeft(2, '0')}';
  }
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

bool isTaskVisibleOn(Task task, DateTime date) {
  final frequency = task.frequency;

  if (frequency.amount == Amount.day &&
      frequency.days != null &&
      frequency.days!.isNotEmpty) {
    return frequency.days!.contains(dayFromWeekday(date.weekday));
  }

  final target = frequency.time ?? 0;
  final current =
      task.progressLog[progressKeyFor(date, frequency.amount ?? Amount.day)] ??
          0;
  return current < target;
}

int currentProgressFor(Task task, DateTime date) {
  final amount = task.frequency.amount ?? Amount.day;
  return task.progressLog[progressKeyFor(date, amount)] ?? 0;
}

bool isTaskCompletedOn(Task task, DateTime date) {
  final target = task.frequency.time ?? 0;
  return currentProgressFor(task, date) >= target;
}
