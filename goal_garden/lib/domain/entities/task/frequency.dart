enum Duration { minutes, hours }

enum Day { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class Frequency {
  final Duration? duration;
  final List<Day>? days;
  final int? time;

  Frequency({this.duration, this.days, this.time});
}
