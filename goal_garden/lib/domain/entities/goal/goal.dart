import 'dart:typed_data';
import 'package:goal_garden/domain/entities/task/task.dart';
import 'package:goal_garden/domain/entities/goal/progress.dart';
import 'package:goal_garden/domain/entities/goal/category.dart';

class Goal {
  final String title;
  final Uint8List? visionBoard;
  final Progress progress;
  final Category? category;
  final List<Task>? tasks;

  Goal(
      {required this.title,
      this.visionBoard,
      required this.progress,
      this.tasks,
      this.category});
}

  /*factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
        name: json['name'],
        imgPath: json['img_path']?.toString() ?? "",
        url: json['url']?.toString() ?? "");
  }

  @override
  String toString() {
    return 'Source : { name: $name, url: $url, imgPath: $imgPath }';
  }*/