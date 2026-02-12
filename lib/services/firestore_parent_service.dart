import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:studycompanion_app/models/child_model.dart';
import 'package:studycompanion_app/models/subject_performance.dart';

/// Service to handle all Firestore operations for Parent Module
class FirestoreParentService {
  static final FirestoreParentService _instance = FirestoreParentService._internal();
  
  factory FirestoreParentService() {
    return _instance;
  }
  
  FirestoreParentService._internal();
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ========== CHILDREN COLLECTION ==========
  
  /// Get all children for a parent
  Future<List<ChildModel>> getChildrenForParent(String parentId) async {
    try {
      final snapshot = await _firestore
          .collection('children')
          .where('parentId', isEqualTo: parentId)
          .get();
      
      final children = <ChildModel>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Get subjects for this child
        final subjectsSnapshot = await _firestore
            .collection('children')
            .doc(doc.id)
            .collection('subjects')
            .get();
        
        final subjects = subjectsSnapshot.docs
            .map((subjectDoc) =>
                SubjectPerformance.fromJson(subjectDoc.data()))
            .toList();
        
        data['subjects'] = subjects;
        
        children.add(ChildModel.fromJson(data));
      }
      
      return children;
    } catch (e) {
      print('❌ Error getting children for parent: $e');
      return [];
    }
  }
  
  /// Stream children for real-time updates
  Stream<List<ChildModel>> streamChildrenForParent(String parentId) {
    return _firestore
        .collection('children')
        .where('parentId', isEqualTo: parentId)
        .snapshots()
        .asyncMap((snapshot) async {
          final children = <ChildModel>[];
          
          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            
            // Get subjects for this child
            final subjectsSnapshot = await _firestore
                .collection('children')
                .doc(doc.id)
                .collection('subjects')
                .get();
            
            final subjects = subjectsSnapshot.docs
                .map((subjectDoc) =>
                    SubjectPerformance.fromJson(subjectDoc.data()))
                .toList();
            
            data['subjects'] = subjects;
            
            children.add(ChildModel.fromJson(data));
          }
          
          return children;
        })
        .handleError((e) {
          print('❌ Error streaming children: $e');
          return <ChildModel>[];
        });
  }
  
  /// Get a specific child by ID
  Future<ChildModel?> getChildById(String childId) async {
    try {
      final doc = await _firestore.collection('children').doc(childId).get();
      
      if (doc.exists) {
        final data = doc.data() ?? {};
        data['id'] = doc.id;
        
        // Get subjects
        final subjectsSnapshot = await _firestore
            .collection('children')
            .doc(childId)
            .collection('subjects')
            .get();
        
        final subjects = subjectsSnapshot.docs
            .map((subjectDoc) =>
                SubjectPerformance.fromJson(subjectDoc.data()))
            .toList();
        
        data['subjects'] = subjects;
        
        return ChildModel.fromJson(data);
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting child: $e');
      return null;
    }
  }
  
  /// Update child information
  Future<bool> updateChild(String childId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('children').doc(childId).update(updates);
      print('✅ Child updated: $childId');
      return true;
    } catch (e) {
      print('❌ Error updating child: $e');
      return false;
    }
  }
  
  /// Update subject performance for a child
  Future<bool> updateSubjectPerformance({
    required String childId,
    required String subjectName,
    required int score,
  }) async {
    try {
      await _firestore
          .collection('children')
          .doc(childId)
          .collection('subjects')
          .doc(subjectName)
          .set({
        'subjectName': subjectName,
        'score': score,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('✅ Subject performance updated: $childId - $subjectName');
      return true;
    } catch (e) {
      print('❌ Error updating subject performance: $e');
      return false;
    }
  }
  
  // ========== PARENT PROFILE COLLECTION ==========
  
  /// Get parent profile
  Future<Map<String, dynamic>?> getParentProfile(String parentId) async {
    try {
      final doc = await _firestore.collection('parents').doc(parentId).get();
      
      if (doc.exists) {
        final data = doc.data() ?? {};
        data['id'] = doc.id;
        return data;
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting parent profile: $e');
      return null;
    }
  }
  
  /// Update parent profile
  Future<bool> updateParentProfile({
    required String parentId,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore.collection('parents').doc(parentId).update(updates);
      print('✅ Parent profile updated: $parentId');
      return true;
    } catch (e) {
      print('❌ Error updating parent profile: $e');
      return false;
    }
  }
  
  // ========== NOTIFICATIONS COLLECTION ==========
  
  /// Get notifications for parent
  Future<List<Map<String, dynamic>>> getParentNotifications(String parentId) async {
    try {
      print('🛠️  DEBUG: Querying notifications with parentId=$parentId');
      final snapshot = await _firestore
          .collection('notifications')
          .where('parentId', isEqualTo: parentId)
          .orderBy('createdAt', descending: true)
          .get();
      
      print('✅ Parent notifications fetched (count=${snapshot.docs.length})');
      if (snapshot.docs.isEmpty) {
        print('⚠️  WARNING: No notifications found for parentId=$parentId - checking all notifications...');
        final allNotifs = await _firestore.collection('notifications').get();
        print('📊 Total notifications in collection: ${allNotifs.docs.length}');
        for (var doc in allNotifs.docs.take(3)) {
          print('   Sample: ${doc.data()}');
        }
      }
      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          })
          .toList();
    } catch (e) {
      print('❌ Error getting parent notifications: $e');
      rethrow;
    }
  }
  
  /// Stream parent notifications for real-time updates
  Stream<List<Map<String, dynamic>>> streamParentNotifications(String parentId) {
    return _firestore
        .collection('notifications')
        .where('parentId', isEqualTo: parentId)
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
          print('❌ Error streaming parent notifications: $e');
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
  
  /// Get unread notification count for parent
  Future<int> getUnreadNotificationCount(String parentId) async {
    try {
      final snapshot = await _firestore
          .collection('notifications')
          .where('parentId', isEqualTo: parentId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting unread notification count: $e');
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
  
  // ========== CALENDAR EVENTS COLLECTION ==========
  
  /// Get calendar events for a parent
  Future<List<Map<String, dynamic>>> getParentCalendarEvents(String parentId) async {
    try {
      final snapshot = await _firestore
          .collection('calendarEvents')
          .where('parentIds', arrayContains: parentId)
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
      print('❌ Error getting calendar events: $e');
      return [];
    }
  }
  
  /// Stream calendar events for real-time updates
  Stream<List<Map<String, dynamic>>> streamParentCalendarEvents(String parentId) {
    return _firestore
        .collection('calendarEvents')
        .where('parentIds', arrayContains: parentId)
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
          print('❌ Error streaming calendar events: $e');
          return <Map<String, dynamic>>[];
        });
  }
  
  /// Get calendar events for a specific child
  Future<List<Map<String, dynamic>>> getChildCalendarEvents(String childId) async {
    try {
      final snapshot = await _firestore
          .collection('calendarEvents')
          .where('childIds', arrayContains: childId)
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
      print('❌ Error getting child calendar events: $e');
      return [];
    }
  }
  
  // ========== TASKS COLLECTION ==========
  
  /// Get tasks for a child (parent view)
  Future<List<Map<String, dynamic>>> getChildTasks(String childId) async {
    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('studentId', isEqualTo: childId)
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
      print('❌ Error getting child tasks: $e');
      return [];
    }
  }
  
  /// Stream tasks for a child (parent view)
  Stream<List<Map<String, dynamic>>> streamChildTasks(String childId) {
    return _firestore
        .collection('tasks')
        .where('studentId', isEqualTo: childId)
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
          print('❌ Error streaming child tasks: $e');
          return <Map<String, dynamic>>[];
        });
  }
  
  // ========== CHILD PROGRESS COLLECTION ==========
  
  /// Get overall progress for a child
  Future<Map<String, dynamic>?> getChildProgress(String childId) async {
    try {
      final doc = await _firestore
          .collection('progress')
          .doc(childId)
          .get();
      
      if (doc.exists) {
        final data = doc.data() ?? {};
        data['id'] = doc.id;
        return data;
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting child progress: $e');
      return null;
    }
  }
  
  /// Stream child progress for real-time updates
  Stream<Map<String, dynamic>?> streamChildProgress(String childId) {
    return _firestore
        .collection('progress')
        .doc(childId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            final data = doc.data() ?? {};
            data['id'] = doc.id;
            return data;
          }
          return null;
        })
        .handleError((e) {
          print('❌ Error streaming child progress: $e');
          return null;
        });
  }
  
  // ========== UTILITY METHODS ==========
  
  /// Get all children IDs for a parent
  Future<List<String>> getChildrenIds(String parentId) async {
    try {
      final snapshot = await _firestore
          .collection('children')
          .where('parentId', isEqualTo: parentId)
          .get();
      
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('❌ Error getting children IDs: $e');
      return [];
    }
  }
  
  /// Get child count for parent
  Future<int> getChildCount(String parentId) async {
    try {
      final snapshot = await _firestore
          .collection('children')
          .where('parentId', isEqualTo: parentId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('❌ Error getting child count: $e');
      return 0;
    }
  }
}
