enum Unit { minutes, hours, count }

enum Day { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class Frequency {
  final Unit? unit;
  final List<Day>? days;
  final int? time;

  Frequency({this.unit, this.days, this.time});
  Map<String, dynamic> toJson() => {
        'unit': unit?.toString().split('.').last,
        'days': days?.map((e) => e.toString().split('.').last).toList(),
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
        time: json['time'],
      );
}
