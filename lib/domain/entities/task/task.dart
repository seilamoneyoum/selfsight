import 'package:selfsight/domain/entities/task/frequency.dart';

class Task {
  final String name;
  final Frequency frequency;
  Task({required this.name, required this.frequency});

  Map<String, dynamic> toJson() => {
        'name': name,
        'frequency': frequency.toJson(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        name: json['name'],
        frequency: Frequency.fromJson(json['frequency']),
      );
}
