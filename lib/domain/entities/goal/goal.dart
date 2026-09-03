import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:selfsight/domain/entities/goal/category.dart';

class Goal {
  final String id;
  String title;
  Progress progress;
  Category? category;
  final String createAt;

  Goal(
      {required this.id,
      required this.title,
      required this.progress,
      this.category,
      required this.createAt});

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'progress': progress.toJson(),
        'category': category?.toString().split('.').last,
        'createAt': createAt,
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'],
        title: json['title'],
        progress: Progress.fromJson(json['progress']),
        category: json['category'] != null
            ? Category.values.firstWhere(
                (e) => e.toString().split('.').last == json['category'])
            : null,
        createAt: json['createAt'],
      );
}
