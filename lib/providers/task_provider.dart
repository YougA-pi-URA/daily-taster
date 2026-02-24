import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

/// Single board metadata
class BoardMeta {
  final String id;
  String name;

  BoardMeta({required this.id, required this.name});

  Map<String, dynamic> toMap() => {'id': id, 'name': name};

  factory BoardMeta.fromMap(Map map) => BoardMeta(
        id: map['id'] as String,
        name: map['name'] as String,
      );
}

class TaskProvider extends ChangeNotifier {
  static const String _boxName = 'tasks';
  static const String _metaBoxName = 'meta';

  late Box<Map> _box;
  late Box _metaBox;

  List<Task> _tasks = [];
  List<BoardMeta> _boards = [];

  /// Currently displayed board id
  String _activeBoardId = 'default';

  // ── public getters ──────────────────────────────────────
  List<BoardMeta> get boards => List.unmodifiable(_boards);
  String get activeBoardId => _activeBoardId;

  BoardMeta get activeBoard =>
      _boards.firstWhere((b) => b.id == _activeBoardId,
          orElse: () => BoardMeta(id: _activeBoardId, name: 'Daily Tasker'));

  String get boardName => activeBoard.name;

  /// Filter for stock section: null = show all
  TaskStatus? _stockFilter;
  TaskStatus? get stockFilter => _stockFilter;

  // ── filtered task lists for active board ────────────────
  List<Task> get _activeTasks =>
      _tasks.where((t) => t.boardId == _activeBoardId).toList();

  List<Task> get tasks => _activeTasks;

  List<Task> get doingTasks =>
      _activeTasks.where((t) => t.status == TaskStatus.doing).toList();

  List<Task> get stockTasks {
    final stock = _activeTasks.where((t) => t.isStock).toList();
    if (_stockFilter != null) {
      return stock.where((t) => t.status == _stockFilter).toList();
    }
    return stock;
  }

  List<Task> get reviewTasks =>
      _activeTasks.where((t) => t.status == TaskStatus.review).toList();

  List<Task> get doneTasks =>
      _activeTasks.where((t) => t.status == TaskStatus.done).toList();

  // Counts
  int get totalTodayTasks =>
      doingTasks.length + reviewTasks.length + doneTasks.length;
  int get completedTasks => doneTasks.length;

  // ── init ────────────────────────────────────────────────
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<Map>(_boxName);
    _metaBox = await Hive.openBox(_metaBoxName);

    _loadBoards();
    _loadTasks();
  }

  void _loadBoards() {
    final raw = _metaBox.get('boards');
    if (raw != null && raw is List && raw.isNotEmpty) {
      _boards = raw
          .map((e) => BoardMeta.fromMap(e as Map))
          .toList();
    } else {
      // 初回 or 旧データ: デフォルトボードを作成
      final oldName =
          (_metaBox.get('boardName') as String?) ?? 'Daily Tasker';
      _boards = [BoardMeta(id: 'default', name: oldName)];
      _saveBoards();
    }

    final savedActive = _metaBox.get('activeBoardId') as String?;
    if (savedActive != null &&
        _boards.any((b) => b.id == savedActive)) {
      _activeBoardId = savedActive;
    } else {
      _activeBoardId = _boards.first.id;
    }
  }

  Future<void> _saveBoards() async {
    await _metaBox.put(
        'boards', _boards.map((b) => b.toMap()).toList());
  }

  void _loadTasks() {
    _tasks = _box.values.map((map) => Task.fromMap(map)).toList();
    _tasks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    notifyListeners();
  }

  // ── board CRUD ──────────────────────────────────────────

  /// Switch active board
  Future<void> switchBoard(String boardId) async {
    if (!_boards.any((b) => b.id == boardId)) return;
    _activeBoardId = boardId;
    _stockFilter = null;
    await _metaBox.put('activeBoardId', boardId);
    notifyListeners();
  }

  /// Add a new board; returns the new board
  Future<BoardMeta> addBoard(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final board = BoardMeta(
        id: id,
        name: name.trim().isEmpty ? 'New Board' : name.trim());
    _boards.add(board);
    await _saveBoards();
    // Immediately switch to new board
    await switchBoard(id);
    return board;
  }

  /// Rename current active board (called from header inline edit)
  Future<void> setBoardName(String name) async {
    await setBoardNameFor(_activeBoardId, name);
  }

  /// Rename a specific board by id (called from side menu)
  Future<void> setBoardNameFor(String boardId, String name) async {
    final idx = _boards.indexWhere((b) => b.id == boardId);
    if (idx == -1) return;
    _boards[idx].name =
        name.trim().isEmpty ? 'Daily Tasker' : name.trim();
    await _saveBoards();
    notifyListeners();
  }

  /// Delete a board and its tasks (cannot delete if only one board)
  Future<void> deleteBoard(String boardId) async {
    if (_boards.length <= 1) return;
    // Delete all tasks belonging to this board
    final ids = _tasks
        .where((t) => t.boardId == boardId)
        .map((t) => t.id)
        .toList();
    for (final id in ids) {
      await _box.delete(id);
    }
    _boards.removeWhere((b) => b.id == boardId);
    await _saveBoards();
    // Switch to first remaining board if active was deleted
    if (_activeBoardId == boardId) {
      await switchBoard(_boards.first.id);
    } else {
      _loadTasks();
    }
  }

  // ── task CRUD (all scoped to activeBoardId) ─────────────

  Future<void> addTask(String title,
      {TaskPriority priority = TaskPriority.normal,
      TaskStatus status = TaskStatus.fresh}) async {
    final task = Task(
        boardId: _activeBoardId,
        title: title,
        priority: priority,
        status: status);
    await _box.put(task.id, task.toMap());
    _loadTasks();
  }

  Future<void> updateTask(Task task) async {
    final updated = task.copyWith();
    await _box.put(updated.id, updated.toMap());
    _loadTasks();
  }

  Future<void> moveTask(String taskId, TaskStatus newStatus) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final updated = _tasks[index].copyWith(status: newStatus);
    await _box.put(updated.id, updated.toMap());
    _loadTasks();
  }

  Future<void> deleteTask(String taskId) async {
    await _box.delete(taskId);
    _loadTasks();
  }

  void setStockFilter(TaskStatus? filter) {
    _stockFilter = filter;
    notifyListeners();
  }

  Future<void> editTask(String taskId,
      {String? title, TaskPriority? priority, String? note}) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    final updated = _tasks[index].copyWith(
      title: title,
      priority: priority,
      note: note,
    );
    await _box.put(updated.id, updated.toMap());
    _loadTasks();
  }

  Future<void> clearDone() async {
    final ids = doneTasks.map((t) => t.id).toList();
    for (final id in ids) {
      await _box.delete(id);
    }
    _loadTasks();
  }
}
