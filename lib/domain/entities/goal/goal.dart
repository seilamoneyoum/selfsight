import 'dart:typed_data';
import 'package:selfsight/domain/entities/task/task.dart';
import 'package:selfsight/domain/entities/goal/progress.dart';
import 'package:selfsight/domain/entities/goal/category.dart';

class Goal {
  final String name;
  final Uint8List? visionBoard;
  final Progress progress;
  final Category? category;
  final List<Task>? tasks;

  Goal(
      {required this.name,
      this.visionBoard,
      required this.progress,
      this.tasks,
      this.category});
}
