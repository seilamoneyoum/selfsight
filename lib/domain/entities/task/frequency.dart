enum Unit { minute, hour, count }

enum Amount { day, week }

enum Day { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

class Frequency {
  Unit? unit;
  Amount? amount;
  List<Day>? days;
  int? time;

  Frequency({this.unit, this.amount, this.days, this.time});
  Map<String, dynamic> toJson() => {
        'unit': unit?.toString().split('.').last,
        'amount': amount?.toString().split('.').last,
        'days': days?.map((e) => e.toString().split('.').last).toList(),
        'time': time,
      };

  factory Frequency.fromJson(Map<String, dynamic> json) => Frequency(
        unit: json['unit'] != null
            ? Unit.values
                .firstWhere((e) => e.toString().split('.').last == json['unit'])
            : null,
        amount: json['amount'] != null
            ? Amount.values.firstWhere(
                (e) => e.toString().split('.').last == json['amount'])
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
