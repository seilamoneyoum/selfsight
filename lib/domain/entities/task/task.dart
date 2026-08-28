import 'package:selfsight/domain/entities/task/frequency.dart';

class Task {
  final String id;
  final String goalId;
  String name;
  Frequency frequency;

  Task({
    required this.id,
    required this.goalId,
    required this.name,
    required this.frequency,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'goalId': goalId,
        'name': name,
        'frequency': frequency.toJson(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        goalId: json['goalId'],
        name: json['name'],
        frequency: Frequency.fromJson(json['frequency']),
      );
}
