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
  final parts = <String>[];

  final time = frequency.time;
  final unit = frequency.unit;
  final amount = frequency.amount;
  if (time != null && unit != null && amount != null) {
    final baseWord = unit == Unit.count ? 'time' : unit.name;
    final word = _pluralize(time, baseWord);
    parts.add('$time $word per ${amount.name}');
  }

  if (frequency.days != null && frequency.days!.isNotEmpty) {
    parts.add(frequency.days!.map(dayLabel).join(', '));
  }

  return parts.isEmpty ? 'No schedule set' : parts.join(' · ');
}

String _pluralize(int count, String singular, [String? plural]) {
  if (count == 1) return singular;
  return plural ?? '${singular}s';
}
