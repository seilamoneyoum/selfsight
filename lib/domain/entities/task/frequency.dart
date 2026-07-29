enum Unit { minutes, hours, count }

enum Day { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

enum Period { week, month }

class Frequency {
  final Unit? unit;
  final List<Day>? days;
  final Period? period;
  final int? time;

  Frequency({this.unit, this.days, this.period, this.time});
  Map<String, dynamic> toJson() => {
        'unit': unit?.toString().split('.').last,
        'days': days?.map((e) => e.toString().split('.').last).toList(),
        'period': period?.toString().split('.').last,
        'time': time,
      };

  factory Frequency.fromJson(Map<String, dynamic> json) => Frequency(
        unit: json['unit'] != null
            ? Unit.values
                .firstWhere((e) => e.toString().split('.').last == json['unit'])
            : null,
        days: json['days'] != null
            ? (json['days'] as List)
                .map((e) => Day.values
                    .firstWhere((d) => d.toString().split('.').last == e))
                .toList()
            : null,
        period: json['period'] != null
            ? Period.values.firstWhere(
                (e) => e.toString().split('.').last == json['period'])
            : null,
        time: json['time'],
      );
}
