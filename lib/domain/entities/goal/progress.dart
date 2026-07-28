import 'priority.dart';

class Progress {
  bool isAccomplished;
  DateTime? startDate;
  DateTime? endDate;
  Priority? priority;

  Progress({
    required this.isAccomplished,
    this.startDate,
    this.endDate,
    this.priority,
  });
  Map<String, dynamic> toJson() => {
        'isAccomplished': isAccomplished,
        'startDate': startDate?.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'priority': priority?.toString().split('.').last,
      };

  factory Progress.fromJson(Map<String, dynamic> json) => Progress(
        isAccomplished: json['isAccomplished'],
        startDate: json['startDate'] != null
            ? DateTime.parse(json['startDate'])
            : null,
        endDate:
            json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
        priority: json['priority'] != null
            ? Priority.values.firstWhere(
                (e) => e.toString().split('.').last == json['priority'])
            : null,
      );
}
