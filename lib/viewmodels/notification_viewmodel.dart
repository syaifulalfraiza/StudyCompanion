import 'package:flutter/foundation.dart';
import 'package:studycompanion_app/models/notification_model.dart';
import 'package:studycompanion_app/services/notification_service.dart';
import 'package:studycompanion_app/services/firestore_student_service.dart';

class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  String _userId = 's1'; // Default to Amir Abdullah (student)
  bool _isStudent = true;
  bool _useFirestore = true; // Use Firestore by default
  
  final FirestoreStudentService _firestoreService = FirestoreStudentService();

  NotificationViewModel({String userId = 's1', bool isStudent = true}) {
    _userId = userId;
    _isStudent = isStudent;
    _initializeNotifications();
  }

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get notificationCount => _notifications.length;

  /// Initialize notifications
  Future<void> _initializeNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      List<Map<String, dynamic>> notificationMaps;
      
      // Use Firestore if enabled
      if (_useFirestore && _isStudent) {
        notificationMaps = await _firestoreService.getStudentNotifications(_userId);
      } else {
        // Fallback to NotificationService
        final previouslyReadIds = _notifications
            .where((n) => n.isRead)
            .map((n) => n.id)
            .toSet();
        final data = _isStudent
            ? await NotificationService.getStudentNotifications(_userId)
            : await NotificationService.getParentNotifications(_userId);

        _notifications = data
            .map((n) => previouslyReadIds.contains(n.id)
                ? n.copyWith(isRead: true)
                : n)
            .toList();
        _unreadCount = _notifications.where((n) => !n.isRead).length;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      // Convert Firestore maps to NotificationModel
      final previouslyReadIds = _notifications
          .where((n) => n.isRead)
          .map((n) => n.id)
          .toSet();
      
      _notifications = notificationMaps
          .map((map) => NotificationModel.fromJson(
              {...map, 'isRead': previouslyReadIds.contains(map['id'])}))
          .toList();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _error = null;
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      print('Error loading notifications: $e');
      // Fallback to sample data
      try {
        final data = _isStudent
            ? await NotificationService.getStudentNotifications(_userId)
            : await NotificationService.getParentNotifications(_userId);
        _notifications = data;
        _unreadCount = _notifications.where((n) => !n.isRead).length;
      } catch (e2) {
        print('Fallback also failed: $e2');
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh notifications
  Future<void> refreshNotifications() async {
    await _initializeNotifications();
  }

  /// Stream notifications for real-time updates
  Stream<List<NotificationModel>> streamNotifications() {
    return _isStudent
        ? NotificationService.streamStudentNotifications(_userId)
        : NotificationService.streamParentNotifications(_userId);
  }

  /// Get recent notifications
  Future<void> loadRecentNotifications() async {
    try {
      final recent = await NotificationService.getRecentNotifications(
        _userId,
        isStudent: _isStudent,
        limit: 5,
      );
      _notifications = recent;
      notifyListeners();
    } catch (e) {
      print('Error loading recent notifications: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // Update locally first for instant UI feedback
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final wasUnread = !_notifications[index].isRead;
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        if (wasUnread && _unreadCount > 0) {
          _unreadCount--;
        }
        notifyListeners();
      }
      
      // Update in Firestore if using Firestore mode
      if (_useFirestore && _isStudent) {
        await _firestoreService.markNotificationAsRead(notificationId);
      } else {
        // Fallback to NotificationService
        await NotificationService.markNotificationAsRead(notificationId);
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  /// Get notifications sorted by date
  List<NotificationModel> get sortedNotifications {
    final sorted = List<NotificationModel>.from(_notifications);
    sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  /// Get notifications by type
  List<NotificationModel> getNotificationsByType(String type) {
    return _notifications.where((n) => n.notificationType == type).toList();
  }

  /// Get unread notifications
  List<NotificationModel> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Get recent notifications (last 5)
  List<NotificationModel> get recentNotifications {
    final sorted = sortedNotifications;
    return sorted.take(5).toList();
  }

  /// Send task reminder
  Future<void> sendTaskReminder(
    String taskTitle,
    String dueDate,
  ) async {
    try {
      if (_isStudent) {
        await NotificationService.sendTaskReminderNotification(
          studentId: _userId,
          taskTitle: taskTitle,
          dueDate: dueDate,
        );
        await refreshNotifications();
      }
    } catch (e) {
      print('Error sending task reminder: $e');
      rethrow;
    }
  }

  /// Send achievement notification
  Future<void> sendAchievement(String achievement) async {
    try {
      if (_isStudent) {
        await NotificationService.sendAchievementNotification(
          studentId: _userId,
          achievement: achievement,
        );
        await refreshNotifications();
      }
    } catch (e) {
      print('Error sending achievement notification: $e');
      rethrow;
    }
  }

  /// Toggle between Firestore and fallback mode
  void setFirestoreMode(bool useFirestore) {
    if (_useFirestore != useFirestore) {
      _useFirestore = useFirestore;
      _initializeNotifications();
    }
  }

  /// Check if using Firestore
  bool get isUsingFirestore => _useFirestore;
}
