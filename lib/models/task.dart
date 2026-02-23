import 'package:uuid/uuid.dart';

/// Task statuses matching the Trello-inspired kanban workflow
enum TaskStatus {
  /// New task just created
  fresh,

  /// On hold / paused
  hold,

  /// Returned - needs re-attention (hand-back)
  returned,

  /// Actively working on it today
  doing,

  /// Handed off - waiting for someone else
  review,

  /// Completed
  done,
}

/// Which source group a stock task belongs to
enum StockOrigin {
  fresh,
  hold,
  returned,
}

/// Priority level for tasks
enum TaskPriority {
  urgent,
  normal,
  low,
}

class Task {
  final String id;
  String title;
  String? note;
  TaskStatus status;
  TaskPriority priority;
  DateTime createdAt;
  DateTime updatedAt;

  Task({
    String? id,
    required this.title,
    this.note,
    this.status = TaskStatus.fresh,
    this.priority = TaskPriority.normal,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Convenience: is this task in the "stock" pool?
  bool get isStock =>
      status == TaskStatus.fresh ||
      status == TaskStatus.hold ||
      status == TaskStatus.returned;

  /// Label for display
  String get statusLabel {
    switch (status) {
      case TaskStatus.fresh:
        return 'NEW';
      case TaskStatus.hold:
        return 'HOLD';
      case TaskStatus.returned:
        return 'RET';
      case TaskStatus.doing:
        return 'DOING';
      case TaskStatus.review:
        return 'REVIEW';
      case TaskStatus.done:
        return 'DONE';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case TaskPriority.urgent:
        return 'URGENT';
      case TaskPriority.normal:
        return 'NORMAL';
      case TaskPriority.low:
        return 'LOW';
    }
  }

  /// Serialize to Map for Hive storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'status': status.index,
      'priority': priority.index,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  /// Deserialize from Map
  factory Task.fromMap(Map<dynamic, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      note: map['note'] as String?,
      status: TaskStatus.values[map['status'] as int],
      priority: TaskPriority.values[map['priority'] as int],
      createdAt:
          DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt:
          DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  Task copyWith({
    String? title,
    String? note,
    TaskStatus? status,
    TaskPriority? priority,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      note: note ?? this.note,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
