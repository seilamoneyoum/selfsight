import 'package:selfsight/domain/entities/task/frequency.dart';

class Task {
  final String id;
  final String goalId;
  String name;
  Frequency frequency;

// <Date, Quantité d'accomplissement>
  Map<String, int> progressLog;

  Task({
    required this.id,
    required this.goalId,
    required this.name,
    required this.frequency,
    Map<String, int>? progressLog,
  }) : progressLog = progressLog ?? {};

  Map<String, dynamic> toJson() => {
        'id': id,
        'goalId': goalId,
        'name': name,
        'frequency': frequency.toJson(),
        'progressLog': progressLog,
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        goalId: json['goalId'],
        name: json['name'],
        frequency: Frequency.fromJson(json['frequency']),
        progressLog: json['progressLog'] != null
            ? Map<String, int>.from(json['progressLog'])
            : {},
      );

  Task copyWith({
    String? id,
    String? goalId,
    String? name,
    Frequency? frequency,
    Map<String, int>? progressLog,
  }) {
    return Task(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      progressLog: progressLog ?? this.progressLog,
    );
  }
}
