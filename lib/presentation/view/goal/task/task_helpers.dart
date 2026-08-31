import 'package:selfsight/domain/entities/task/frequency.dart';

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
