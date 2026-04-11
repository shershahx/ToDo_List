import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:to_do_list/models/task_item.dart';
import 'package:to_do_list/utils/notification_service.dart';
import 'package:to_do_list/utils/session_manager.dart';

class TaskProvider extends ChangeNotifier {
  List<TaskItem> _tasks = [];
  bool _isInitialized = false;

  final _storage = const FlutterSecureStorage();
  
  String get _tasksKey => 'tasks_${SessionManager().currentEmail ?? 'default'}';

  List<TaskItem> get tasks => _tasks;
  bool get isInitialized => _isInitialized;

  // Derive counts easily from the single source of truth
  int get totalCount => _tasks.length;
  int get doneCount => _tasks.where((t) => t.done).length;

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final raw = await _storage.read(key: _tasksKey);
    if (raw != null) {
      try {
        final List decoded = jsonDecode(raw) as List;
        _tasks = decoded
            .map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        _tasks = [];
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    await _storage.write(
      key: _tasksKey,
      value: jsonEncode(_tasks.map((t) => t.toJson()).toList()),
    );
  }

  void addTask(String title, DateTime? dueDate, {String category = 'none'}) {
    final task = TaskItem(title: title.trim(), dueDate: dueDate, category: category);
    _tasks.add(task);
    notifyListeners();
    _saveTasks();

    if (dueDate != null && dueDate.isAfter(DateTime.now())) {
      NotificationService().scheduleTaskReminder(
        id: task.hashCode,
        title: task.title,
        scheduledDate: dueDate,
      );
    }
  }

  void toggleTask(int index) {
    if (index < 0 || index >= _tasks.length) return;
    
    final task = _tasks[index];
    final nowDone = !task.done;
    _tasks[index] = task.copyWith(done: nowDone);
    
    notifyListeners();
    _saveTasks();

    if (nowDone) {
      NotificationService().cancel(task.hashCode);
    } else if (task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
      NotificationService().scheduleTaskReminder(
        id: task.hashCode,
        title: task.title,
        scheduledDate: task.dueDate!,
      );
    }
  }

  void deleteTask(int index) {
    if (index < 0 || index >= _tasks.length) return;

    final removed = _tasks.removeAt(index);
    notifyListeners();
    _saveTasks();

    NotificationService().cancel(removed.hashCode);
  }

  void restoreTask(int index, TaskItem task) {
    _tasks.insert(index, task);
    notifyListeners();
    _saveTasks();

    if (task.dueDate != null &&
        task.dueDate!.isAfter(DateTime.now()) &&
        !task.done) {
      NotificationService().scheduleTaskReminder(
        id: task.hashCode,
        title: task.title,
        scheduledDate: task.dueDate!,
      );
    }
  }
}
