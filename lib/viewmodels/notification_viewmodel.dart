import 'package:flutter/foundation.dart';
import 'package:studycompanion_app/models/notification_model.dart';
import 'package:studycompanion_app/services/notification_service.dart';
import 'package:studycompanion_app/services/firestore_student_service.dart';
import 'package:studycompanion_app/services/firestore_parent_service.dart';

class NotificationViewModel extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  String _userId = 's1'; // Default to Amir Abdullah (student)
  bool _isStudent = true;
  bool _useFirestore = true; // Use Firestore by default
  
  final FirestoreStudentService _firestoreStudentService = FirestoreStudentService();
  final FirestoreParentService _firestoreParentService = FirestoreParentService();

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
      List<Map<String, dynamic>> notificationMaps = [];
      
      // Use Firestore if enabled
      if (_useFirestore) {
        final sourceLabel = _isStudent ? 'student' : 'parent';
        print('🧭 Notifications source: Firestore ($sourceLabel) for user=$_userId');
        try {
          notificationMaps = _isStudent
          ? await _firestoreStudentService.getStudentNotifications(_userId)
          : await _firestoreParentService.getParentNotifications(_userId);
        } catch (firestoreError) {
          print('🧭 Firestore error (will try fallback): $firestoreError');
        }
      }
      
      // If Firestore returned empty or error, try fallback service
      if (notificationMaps.isEmpty) {
        try {
          final previouslyReadIds = _notifications
              .where((n) => n.isRead)
              .map((n) => n.id)
              .toSet();
            print('🧭 Notifications source: fallback service for user=$_userId');
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
        } catch (fallbackError) {
          print('Fallback service also failed: $fallbackError');
        }
      }

      // Convert Firestore maps to NotificationModel if we have data
      if (notificationMaps.isNotEmpty) {
        final previouslyReadIds = _notifications
            .where((n) => n.isRead)
            .map((n) => n.id)
            .toSet();
        
        _notifications = notificationMaps
            .map((map) => NotificationModel.fromJson(
                {...map, 'isRead': previouslyReadIds.contains(map['id'])}))
            .toList();
      } else {
        // Use sample notifications if all else fails
        _notifications = _getSampleNotifications();
      }
      
      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _error = null;
    } catch (e) {
      _error = 'Failed to load notifications: $e';
      print('Error loading notifications: $e');
      // Use sample data as final fallback
      _notifications = _getSampleNotifications();
      _unreadCount = _notifications.where((n) => !n.isRead).length;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Get sample notifications
  List<NotificationModel> _getSampleNotifications() {
    return [
      NotificationModel(
        id: 'notif1',
        title: 'Assignment Submitted',
        body: 'Your Physics assignment has been submitted successfully.',
        notificationType: 'assignment',
        isRead: false,
        createdAt: DateTime.now(),
      ),
      NotificationModel(
        id: 'notif2',
        title: 'Grade Posted',
        body: 'Your Mathematics test has been graded. Check results now.',
        notificationType: 'grade',
        isRead: false,
        createdAt: DateTime.now().subtract(Duration(hours: 1)),
      ),
      NotificationModel(
        id: 'notif3',
        title: 'Class Reminder',
        body: 'Chemistry class starts in 30 minutes. Be on time!',
        notificationType: 'reminder',
        isRead: false,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
      ),
      NotificationModel(
        id: 'notif4',
        title: 'New Homework',
        body: 'Mr. Ahmed has posted new homework for English class.',
        notificationType: 'homework',
        isRead: true,
        createdAt: DateTime.now().subtract(Duration(hours: 4)),
      ),
    ];
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
      if (_useFirestore) {
        if (_isStudent) {
          await _firestoreStudentService.markNotificationAsRead(notificationId);
        } else {
          await _firestoreParentService.markNotificationAsRead(notificationId);
        }
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
