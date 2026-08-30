import 'package:selfsight/domain/entities/task/task.dart';
import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:selfsight/domain/entities/goal/category.dart';

class Goal {
  final String id;
  String title;
  String? visionBoardPath;
  Progress progress;
  Category? category;
  final String createAt;

  Goal(
      {required this.id,
      required this.title,
      this.visionBoardPath,
      required this.progress,
      this.category,
      required this.createAt});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'visionBoardPath': visionBoardPath,
        'progress': progress.toJson(),
        'category': category?.toString().split('.').last,
        'createAt': createAt,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'],
        title: json['title'],
        visionBoardPath: json['visionBoardPath'],
        progress: Progress.fromJson(json['progress']),
        category: json['category'] != null
            ? Category.values.firstWhere(
                (e) => e.toString().split('.').last == json['category'])
            : null,
        createAt: json['createAt'],
      );
}
