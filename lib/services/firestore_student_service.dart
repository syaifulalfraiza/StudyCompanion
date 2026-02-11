import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studycompanion_app/models/task_model.dart';

/// Service to handle all Firestore operations for Student Module
class FirestoreStudentService {
  static final FirestoreStudentService _instance = FirestoreStudentService._internal();
  
  factory FirestoreStudentService() {
    return _instance;
  }
  
  FirestoreStudentService._internal();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ========== TASKS COLLECTION ==========
  
  /// Get all tasks for a student
  Future<List<Task>> getStudentTasks(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('studentId', isEqualTo: studentId)
          .get();
      
      final tasks = snapshot.docs
          .map((doc) => Task.fromJson(doc.data(), doc.id))
          .toList();
      
      // Sort by dueDate in code
      tasks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
      
      return tasks;
    } catch (e) {
      print('❌ Error getting student tasks: $e');
      return [];
    }
  }
  
  /// Stream tasks for real-time updates
  Stream<List<Task>> streamStudentTasks(String studentId) {
    return _firestore
        .collection('tasks')
        .where('studentId', isEqualTo: studentId)
        .snapshots()
        .map(
          (snapshot) {
            final tasks = snapshot.docs
                .map((doc) => Task.fromJson(doc.data(), doc.id))
                .toList();
            // Sort by dueDate in code
            tasks.sort((a, b) => b.dueDate.compareTo(a.dueDate));
            return tasks;
          },
        )
        .handleError((e) {
          print('❌ Error streaming student tasks: $e');
          return <Task>[];
        });
  }
  
  /// Create a new task
  Future<String?> createTask({
    required String studentId,
    required String title,
    required String subject,
    required String dueDate,
  }) async {
    try {
      final docRef = await _firestore.collection('tasks').add({
        'studentId': studentId,
        'title': title,
        'subject': subject,
        'dueDate': dueDate,
        'isCompleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Task created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error creating task: $e');
      return null;
    }
  }
  
  /// Toggle task completion status
  Future<bool> toggleTaskCompletion({
    required String taskId,
    required bool isCompleted,
  }) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'isCompleted': isCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Task completion toggled: $taskId');
      return true;
    } catch (e) {
      print('❌ Error toggling task completion: $e');
      return false;
    }
  }
  
  /// Update a task
  Future<bool> updateTask({
    required String taskId,
    required String title,
    required String subject,
    required String dueDate,
  }) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'title': title,
        'subject': subject,
        'dueDate': dueDate,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ Task updated: $taskId');
      return true;
    } catch (e) {
      print('❌ Error updating task: $e');
      return false;
    }
  }
  
  /// Delete a task
  Future<bool> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
      print('✅ Task deleted: $taskId');
      return true;
    } catch (e) {
      print('❌ Error deleting task: $e');
      return false;
    }
  }
  
  /// Get task count for student
  Future<int> getTaskCount(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('studentId', isEqualTo: studentId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting task count: $e');
      return 0;
    }
  }
  
  /// Get completed task count for student
  Future<int> getCompletedTaskCount(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('studentId', isEqualTo: studentId)
          .where('isCompleted', isEqualTo: true)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting completed task count: $e');
      return 0;
    }
  }
  
  // ========== ANNOUNCEMENTS COLLECTION ==========
  
  /// Get published announcements
  Future<List<Map<String, dynamic>>> getPublishedAnnouncements() async {
    try {
      final snapshot = await _firestore
          .collection('announcements')
          .where('isPublished', isEqualTo: true)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .toList();
    } catch (e) {
      print('❌ Error getting announcements: $e');
      return [];
    }
  }
  
  /// Stream announcements for real-time updates
  Stream<List<Map<String, dynamic>>> streamPublishedAnnouncements() {
    return _firestore
        .collection('announcements')
        .where('isPublished', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              })
              .toList(),
        )
        .handleError((e) {
          print('❌ Error streaming announcements: $e');
          return <Map<String, dynamic>>[];
        });
  }
  
  // ========== NOTIFICATIONS COLLECTION ==========
  
  /// Get notifications for student
  Future<List<Map<String, dynamic>>> getStudentNotifications(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: studentId)
          .where('recipientType', isEqualTo: 'student')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .toList();
    } catch (e) {
      print('❌ Error getting student notifications: $e');
      return [];
    }
  }
  
  /// Stream student notifications for real-time updates
  Stream<List<Map<String, dynamic>>> streamStudentNotifications(String studentId) {
    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: studentId)
        .where('recipientType', isEqualTo: 'student')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) {
                final data = doc.data();
                data['id'] = doc.id;
                return data;
              })
              .toList(),
        )
        .handleError((e) {
          print('❌ Error streaming notifications: $e');
          return <Map<String, dynamic>>[];
        });
  }
  
  /// Mark notification as read
  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
      print('✅ Notification marked as read: $notificationId');
      return true;
    } catch (e) {
      print('❌ Error marking notification as read: $e');
      return false;
    }
  }
  
  /// Get unread notification count for student
  Future<int> getUnreadNotificationCount(String studentId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('recipientId', isEqualTo: studentId)
          .where('recipientType', isEqualTo: 'student')
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting unread notification count: $e');
      return 0;
    }
  }
  
  // ========== STUDENT PROFILE COLLECTION ==========
  
  /// Get student profile
  Future<Map<String, dynamic>?> getStudentProfile(String studentId) async {
    try {
      final doc = await _firestore
          .collection('students')
          .doc(studentId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() ?? {};
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('❌ Error getting student profile: $e');
      return null;
    }
  }
  
  /// Update student profile
  Future<bool> updateStudentProfile({
    required String studentId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore
          .collection('students')
          .doc(studentId)
          .update(updates);
      print('✅ Student profile updated: $studentId');
      return true;
    } catch (e) {
      print('❌ Error updating student profile: $e');
      return false;
    }
  }
}
