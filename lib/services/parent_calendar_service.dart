import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class ParentCalendarService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'parent_calendar_events';

  static Map<String, dynamic> _mapEventDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
    String fallbackParentId,
  ) {
    final data = doc.data();
    DateTime date = DateTime.now();

    final dateField = data['date'];
    if (dateField is Timestamp) {
      date = dateField.toDate();
    } else if (dateField is DateTime) {
      date = dateField;
    }

    return {
      'id': doc.id,
      'parentId': data['parentId'] ?? fallbackParentId,
      'title': data['title'] ?? '',
      'time': data['time'] ?? '',
      'type': data['type'] ?? 'school_event',
      'description': data['description'] ?? '',
      'childName': data['childName'],
      'visibilityScope': data['visibilityScope'] ?? 'private',
      'allowedRoles': (data['allowedRoles'] as List?)?.cast<String>() ?? [],
      'audienceUserIds':
          (data['audienceUserIds'] as List?)?.cast<String>() ?? [],
      'createdByUserId': data['createdByUserId'],
      'createdByRole': data['createdByRole'],
      'date': date,
    };
  }

  static Stream<List<Map<String, dynamic>>> streamParentEvents({
    required String parentId,
    String role = 'parent',
  }) {
    final controller = StreamController<List<Map<String, dynamic>>>();
    List<Map<String, dynamic>> privateEvents = [];
    List<Map<String, dynamic>> globalEvents = [];
    List<Map<String, dynamic>> roleEvents = [];

    void emitCombined() {
      final Map<String, Map<String, dynamic>> merged = {};
      for (final list in [privateEvents, globalEvents, roleEvents]) {
        for (final event in list) {
          final id = event['id'] as String?;
          if (id == null || id.isEmpty) continue;
          merged[id] = event;
        }
      }

      final combined = merged.values.toList();
      combined.sort((a, b) {
        final dateA = a['date'] as DateTime? ?? DateTime.now();
        final dateB = b['date'] as DateTime? ?? DateTime.now();
        return dateA.compareTo(dateB);
      });

      if (!controller.isClosed) {
        controller.add(combined);
      }
    }

    StreamSubscription? privateSub;
    StreamSubscription? globalSub;
    StreamSubscription? roleSub;

    controller.onListen = () {
      privateSub = _firestore
          .collection(_collectionName)
          .where('parentId', isEqualTo: parentId)
          .orderBy('date', descending: false)
          .snapshots()
          .listen((snapshot) {
            privateEvents = snapshot.docs
                .map((doc) => _mapEventDocument(doc, parentId))
                .toList();
            emitCombined();
          });

      globalSub = _firestore
          .collection(_collectionName)
          .where('visibilityScope', isEqualTo: 'global')
          .orderBy('date', descending: false)
          .snapshots()
          .listen((snapshot) {
            globalEvents = snapshot.docs
                .map((doc) => _mapEventDocument(doc, parentId))
                .toList();
            emitCombined();
          });

      roleSub = _firestore
          .collection(_collectionName)
          .where('visibilityScope', isEqualTo: 'role')
          .where('allowedRoles', arrayContains: role)
          .orderBy('date', descending: false)
          .snapshots()
          .listen((snapshot) {
            roleEvents = snapshot.docs
                .map((doc) => _mapEventDocument(doc, parentId))
                .toList();
            emitCombined();
          });
    };

    controller.onCancel = () async {
      await privateSub?.cancel();
      await globalSub?.cancel();
      await roleSub?.cancel();
    };

    return controller.stream;
  }

  static Future<void> createEvent({
    required String parentId,
    required String title,
    required String time,
    required String type,
    required DateTime date,
    String? description,
    String? childName,
    String visibilityScope = 'private',
    List<String> allowedRoles = const [],
    List<String>? audienceUserIds,
    String? createdByUserId,
    String? createdByRole,
  }) async {
    final docRef = _firestore.collection(_collectionName).doc();
    final role = (createdByRole ?? 'parent').toLowerCase();
    final effectiveVisibility = role == 'admin' ? visibilityScope : 'private';
    final effectiveAllowedRoles = role == 'admin' ? allowedRoles : const [];
    final effectiveAudience = role == 'admin'
        ? (audienceUserIds ?? [parentId])
        : [parentId];
    await docRef.set({
      'parentId': parentId,
      'title': title,
      'time': time,
      'type': type,
      'description': description ?? '',
      'childName': childName,
      'date': Timestamp.fromDate(date),
      'visibilityScope': effectiveVisibility,
      'allowedRoles': effectiveAllowedRoles,
      'audienceUserIds': effectiveAudience,
      'createdByUserId': createdByUserId ?? parentId,
      'createdByRole': createdByRole ?? 'parent',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateEvent({
    required String eventId,
    required String title,
    required String time,
    required String type,
    required DateTime date,
    String? description,
    String? childName,
    String? visibilityScope,
    List<String>? allowedRoles,
    List<String>? audienceUserIds,
    String? updatedByUserId,
    String? updatedByRole,
  }) async {
    final role = (updatedByRole ?? 'parent').toLowerCase();
    await _firestore.collection(_collectionName).doc(eventId).update({
      'title': title,
      'time': time,
      'type': type,
      'description': description ?? '',
      'childName': childName,
      'date': Timestamp.fromDate(date),
      if (role == 'admin' && visibilityScope != null)
        'visibilityScope': visibilityScope,
      if (role == 'admin' && allowedRoles != null) 'allowedRoles': allowedRoles,
      if (role == 'admin' && audienceUserIds != null)
        'audienceUserIds': audienceUserIds,
      if (updatedByUserId != null) 'updatedByUserId': updatedByUserId,
      if (updatedByRole != null) 'updatedByRole': updatedByRole,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(_collectionName).doc(eventId).delete();
  }
}
