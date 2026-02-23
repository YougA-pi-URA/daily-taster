import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskProvider extends ChangeNotifier {
  static const String _boxName = 'tasks';
  late Box<Map> _box;
  List<Task> _tasks = [];

  /// Filter for stock section: null = show all, or a specific origin
  TaskStatus? _stockFilter;
  TaskStatus? get stockFilter => _stockFilter;

  List<Task> get tasks => _tasks;

  // Filtered lists for each kanban section
  List<Task> get doingTasks =>
      _tasks.where((t) => t.status == TaskStatus.doing).toList();

  List<Task> get stockTasks {
    final stock = _tasks.where((t) => t.isStock).toList();
    if (_stockFilter != null) {
      return stock.where((t) => t.status == _stockFilter).toList();
    }
    return stock;
  }

  List<Task> get reviewTasks =>
      _tasks.where((t) => t.status == TaskStatus.review).toList();

  List<Task> get doneTasks =>
      _tasks.where((t) => t.status == TaskStatus.done).toList();

  // Counts
  int get totalTodayTasks => doingTasks.length + reviewTasks.length + doneTasks.length;
  int get completedTasks => doneTasks.length;

  /// Initialize Hive and load tasks
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
    _loadTasks();
  }

  void _loadTasks() {
    _tasks = _box.values
        .map((map) => Task.fromMap(map))
        .toList();
    // Sort: most recent first within each group
    _tasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  /// Add a new task (defaults to "fresh" status)
  Future<void> addTask(String title, {TaskPriority priority = TaskPriority.normal, TaskStatus status = TaskStatus.fresh}) async {
    final task = Task(title: title, priority: priority, status: status);
    await _box.put(task.id, task.toMap());
    _loadTasks();
  }

  /// Update a task
  Future<void> updateTask(Task task) async {
    final updated = task.copyWith();
    await _box.put(updated.id, updated.toMap());
    _loadTasks();
  }

  /// Move a task to a new status
  Future<void> moveTask(String taskId, TaskStatus newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = _tasks[index];
    final updated = task.copyWith(status: newStatus);
    await _box.put(updated.id, updated.toMap());
    _loadTasks();
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    await _box.delete(taskId);
    _loadTasks();
  }

  /// Set stock filter
  void setStockFilter(TaskStatus? filter) {
    _stockFilter = filter;
    notifyListeners();
  }

  /// Edit task title and priority
  Future<void> editTask(String taskId, {String? title, TaskPriority? priority, String? note}) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final task = _tasks[index];
    final updated = task.copyWith(
      title: title,
      priority: priority,
      note: note,
    );
    await _box.put(updated.id, updated.toMap());
    _loadTasks();
  }

  /// Clear all completed tasks
  Future<void> clearDone() async {
    final doneIds = doneTasks.map((t) => t.id).toList();
    for (final id in doneIds) {
      await _box.delete(id);
    }
    _loadTasks();
  }
}
