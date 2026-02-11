import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:studycompanion_app/core/user_session.dart';
import 'package:studycompanion_app/models/task_model.dart';
import 'package:studycompanion_app/services/task_service.dart';

class StudentDashboardViewModel extends ChangeNotifier {
  late List<Task> _tasks;
  final String _studentId;
  StreamSubscription<List<Task>>? _tasksSubscription;
  bool _isLoading = false;
  String? _error;

  StudentDashboardViewModel({String? studentId})
    : _studentId = (studentId != null && studentId.isNotEmpty)
          ? studentId
          : (UserSession.userId.isNotEmpty ? UserSession.userId : 's1') {
    _initializeTasks();
    _subscribeToTasks();
  }

  void _initializeTasks() {
    _tasks = [
      Task(
        id: '1',
        title: 'Algebra Worksheet',
        dueDate: 'Due Today',
        subject: 'Mathematics',
      ),
      Task(
        id: '2',
        title: 'Chapter 4 Reading',
        dueDate: 'Due Tomorrow',
        subject: 'English',
      ),
      Task(
        id: '3',
        title: 'Lab Report Draft',
        dueDate: 'Due Friday',
        subject: 'Science',
      ),
      Task(
        id: '4',
        title: 'History Essay Outline',
        dueDate: 'Next Week',
        subject: 'History',
      ),
    ];
  }

  void _subscribeToTasks() {
    _isLoading = true;
    notifyListeners();

    _tasksSubscription?.cancel();
    _tasksSubscription = TaskService.streamStudentTasks(_studentId).listen(
      (tasks) {
        _tasks = tasks;
        _error = null;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _error = 'Failed to load tasks: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get overall progress percentage
  double get overallProgress {
    if (_tasks.isEmpty) return 0;
    int completedCount = _tasks.where((task) => task.isCompleted).length;
    return completedCount / _tasks.length;
  }

  // Get overall progress as percentage (0-100)
  int get progressPercentage => (overallProgress * 100).toInt();

  // Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final newValue = !_tasks[taskIndex].isCompleted;
      _tasks[taskIndex].isCompleted = newValue;
      notifyListeners();
      await TaskService.toggleTaskCompletion(
        taskId: taskId,
        isCompleted: newValue,
      );
    }
  }

  // Add a new task
  Future<void> addTask({
    required String title,
    required String dueDate,
    required String subject,
  }) {
    return TaskService.createTask(
      studentId: _studentId,
      title: title,
      subject: subject,
      dueDate: dueDate,
    );
  }

  // Update an existing task
  Future<void> updateTask(Task updatedTask) async {
    await TaskService.updateTask(
      taskId: updatedTask.id,
      title: updatedTask.title,
      subject: updatedTask.subject,
      dueDate: updatedTask.dueDate,
    );
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await TaskService.deleteTask(taskId);
  }

  // Get completed tasks count
  int get completedTasksCount =>
      _tasks.where((task) => task.isCompleted).length;

  // Get total tasks count
  int get totalTasksCount => _tasks.length;

  // Get pending tasks count
  int get pendingTasksCount => _tasks.where((task) => !task.isCompleted).length;

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    super.dispose();
  }
}
