enum Priority { none, low, medium, high }

class Progress {
  final bool isAccomplished;
  final DateTime? startDate;
  final DateTime? endDate;
  final Priority? priority;

  Progress({
    required this.isAccomplished,
    this.startDate,
    this.endDate,
    this.priority,
  });
}
