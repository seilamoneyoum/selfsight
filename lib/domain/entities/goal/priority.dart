import 'package:flutter/material.dart';

enum Priority { none, low, medium, high }

extension PriorityExtension on Priority {
  String get level {
    switch (this) {
      case Priority.high:
        return "High";
      case Priority.medium:
        return "Medium";
      case Priority.low:
        return "Low";
      case Priority.none:
        return "None";
    }
  }

  IconData get icon {
    switch (this) {
      case Priority.high:
        return Icons.signal_cellular_alt;
      case Priority.medium:
        return Icons.signal_cellular_alt_2_bar;
      case Priority.low:
        return Icons.signal_cellular_alt_1_bar;
      case Priority.none:
        return Icons.block;
    }
  }
}
