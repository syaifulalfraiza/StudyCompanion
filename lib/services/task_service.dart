import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studycompanion_app/models/task_model.dart';

class TaskService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'tasks';

  /// Get tasks for a student
  static Future<List<Task>> getStudentTasks(String studentId) async {
    final querySnapshot = await _firestore
        .collection(_collectionName)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Task.fromJson(doc.data(), doc.id))
        .toList();
  }

  /// Stream tasks for real-time updates
  static Stream<List<Task>> streamStudentTasks(String studentId) {
    return _firestore
        .collection(_collectionName)
        .where('studentId', isEqualTo: studentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (querySnapshot) => querySnapshot.docs
              .map((doc) => Task.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  /// Create a new task
  static Future<void> createTask({
    required String studentId,
    required String title,
    required String subject,
    required String dueDate,
  }) async {
    await _firestore.collection(_collectionName).add({
      'studentId': studentId,
      'title': title,
      'subject': subject,
      'dueDate': dueDate,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update an existing task
  static Future<void> updateTask({
    required String taskId,
    required String title,
    required String subject,
    required String dueDate,
  }) async {
    await _firestore.collection(_collectionName).doc(taskId).update({
      'title': title,
      'subject': subject,
      'dueDate': dueDate,
    });
  }

  /// Toggle completion
  static Future<void> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    await _firestore.collection(_collectionName).doc(taskId).update({
      'isCompleted': isCompleted,
    });
  }

  /// Delete a task
  static Future<void> deleteTask(String taskId) async {
    await _firestore.collection(_collectionName).doc(taskId).delete();
  }
}
