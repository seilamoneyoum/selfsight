enum Unit { minutes, hours, count }

enum Day { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

enum Period { week, month }

class Frequency {
  final Unit? unit;
  final List<Day>? days;
  final Period? period;
  final int? time;

  Frequency({this.unit, this.days, this.period, this.time});
}
