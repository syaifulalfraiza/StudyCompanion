import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/calendar_event_model.dart';

class FirestoreCalendarEventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'calendar_events';

  CalendarEventModel _applyVisibilityRules(CalendarEventModel event) {
    final role = (event.createdByRole ?? '').toLowerCase();
    final ownerId = event.userId ?? event.createdByUserId ?? '';

    if (role == 'admin') {
      return event;
    }

    if (role == 'teacher') {
      if (event.visibilityScope == 'role') {
        final allowed = event.allowedRoles
            .where((r) => r == 'teacher' || r == 'student')
            .toList();
        return event.copyWith(
          visibilityScope: 'role',
          allowedRoles: allowed.isEmpty ? ['teacher'] : allowed,
          audienceUserIds: const [],
        );
      }
    }

    return event.copyWith(
      visibilityScope: 'private',
      allowedRoles: const [],
      audienceUserIds: ownerId.isNotEmpty ? [ownerId] : const [],
    );
  }

  Query<Map<String, dynamic>> _baseDateRangeQuery(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _firestore
        .collection(_collection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: false);
  }

  Future<List<CalendarEventModel>> _fetchEventsFromQuery(
    Query<Map<String, dynamic>> query,
  ) async {
    final querySnapshot = await query.get();
    return querySnapshot.docs
        .map(
          (doc) => CalendarEventModel.fromMap(doc.data(), documentId: doc.id),
        )
        .toList();
  }

  List<CalendarEventModel> _mergeAndSortEvents(
    List<List<CalendarEventModel>> lists,
  ) {
    final Map<String, CalendarEventModel> unique = {};
    for (final list in lists) {
      for (final event in list) {
        if (event.id.isEmpty) continue;
        unique[event.id] = event;
      }
    }
    final merged = unique.values.toList();
    merged.sort((a, b) => a.date.compareTo(b.date));
    return merged;
  }

  Future<List<CalendarEventModel>> _getEventsForAudienceByDateRange(
    String userId,
    String role,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final baseQuery = _baseDateRangeQuery(startDate, endDate);
      final futures = <Future<List<CalendarEventModel>>>[
        _fetchEventsFromQuery(baseQuery.where('userId', isEqualTo: userId)),
        _fetchEventsFromQuery(
          baseQuery.where('audienceUserIds', arrayContains: userId),
        ),
        _fetchEventsFromQuery(
          baseQuery.where('visibilityScope', isEqualTo: 'global'),
        ),
      ];

      if (role.isNotEmpty) {
        futures.add(
          _fetchEventsFromQuery(
            baseQuery
                .where('visibilityScope', isEqualTo: 'role')
                .where('allowedRoles', arrayContains: role),
          ),
        );
      }

      final results = await Future.wait(futures);
      return _mergeAndSortEvents(results);
    } catch (e) {
      print('Error fetching events for audience: $e');
      return [];
    }
  }

  // Get all events for a specific user
  Future<List<CalendarEventModel>> getEventsForUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => CalendarEventModel.fromMap(doc.data(), documentId: doc.id),
          )
          .toList();
    } catch (e) {
      print('Error fetching events for user: $e');
      return [];
    }
  }

  // Get events for a specific date range
  Future<List<CalendarEventModel>> getEventsByDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => CalendarEventModel.fromMap(doc.data(), documentId: doc.id),
          )
          .toList();
    } catch (e) {
      print('Error fetching events by date range: $e');
      return [];
    }
  }

  // Get sample calendar events for the month
  List<CalendarEventModel> _getSampleCalendarEvents(
    String userId,
    int year,
    int month,
  ) {
    final today = DateTime.now();
    final lastDay = DateTime(year, month + 1, 0).day;
    return [
      CalendarEventModel(
        id: 'sample_event_1',
        title: 'Math Quiz',
        description: 'Chapter 3-5 Comprehensive Assessment',
        date: DateTime(year, month, max(today.day - 2, 1), 10, 0),
        type: EventType.exam,
        userId: userId,
        classroomId: 'sample_class_1',
        visibilityScope: 'classroom',
        allowedRoles: ['student', 'teacher'],
        createdByUserId: userId,
        createdByRole: 'teacher',
        createdAt: DateTime.now(),
      ),
      CalendarEventModel(
        id: 'sample_event_2',
        title: 'Science Project Submission',
        description: 'Submit your renewable energy research project',
        date: DateTime(year, month, min(today.day + 5, lastDay), 23, 59),
        type: EventType.deadline,
        userId: userId,
        classroomId: 'sample_class_1',
        visibilityScope: 'classroom',
        allowedRoles: ['student', 'teacher'],
        createdByUserId: userId,
        createdByRole: 'teacher',
        createdAt: DateTime.now(),
      ),
      CalendarEventModel(
        id: 'sample_event_3',
        title: 'Parent-Teacher Meeting',
        description: 'Quarterly progress review and feedback session',
        date: DateTime(year, month, min(today.day + 10, lastDay), 15, 0),
        type: EventType.meeting,
        userId: userId,
        classroomId: 'sample_class_1',
        visibilityScope: 'role',
        allowedRoles: ['teacher'],
        createdByUserId: userId,
        createdByRole: 'teacher',
        createdAt: DateTime.now(),
      ),
      CalendarEventModel(
        id: 'sample_event_4',
        title: 'Class Field Trip',
        description: 'Visit to the Natural History Museum',
        date: DateTime(year, month, min(today.day + 15, lastDay), 9, 0),
        type: EventType.event,
        userId: userId,
        classroomId: 'sample_class_1',
        visibilityScope: 'classroom',
        allowedRoles: ['student', 'teacher'],
        createdByUserId: userId,
        createdByRole: 'teacher',
        createdAt: DateTime.now(),
      ),
      CalendarEventModel(
        id: 'sample_event_5',
        title: 'Exam Day',
        description: 'Final exam covering all units',
        date: DateTime(year, month, min(today.day + 20, lastDay), 9, 0),
        type: EventType.exam,
        userId: userId,
        classroomId: 'sample_class_1',
        visibilityScope: 'classroom',
        allowedRoles: ['student', 'teacher'],
        createdByUserId: userId,
        createdByRole: 'teacher',
        createdAt: DateTime.now(),
      ),
    ];
  }

  // Get events for a specific month
  Future<List<CalendarEventModel>> getEventsForMonth(
    String userId,
    int year,
    int month, {
    String role = '',
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    try {
      final events = await _getEventsForAudienceByDateRange(userId, role, startDate, endDate);
      
      // Fallback to sample events if no events found
      if (events.isEmpty) {
        print('No events found in Firestore, using sample calendar events');
        return _getSampleCalendarEvents(userId, year, month);
      }
      
      return events;
    } catch (e) {
      print('Error fetching events: $e, using sample calendar events');
      return _getSampleCalendarEvents(userId, year, month);
    }
  }

  // Get events for a specific classroom
  Future<List<CalendarEventModel>> getEventsForClassroom(
    String classroomId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('classroomId', isEqualTo: classroomId)
          .orderBy('date', descending: false)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => CalendarEventModel.fromMap(doc.data(), documentId: doc.id),
          )
          .toList();
    } catch (e) {
      print('Error fetching events for classroom: $e');
      return [];
    }
  }

  // Create a new event
  Future<void> createEvent(CalendarEventModel event) async {
    try {
      final sanitizedEvent = _applyVisibilityRules(event);
      await _firestore
          .collection(_collection)
          .doc(sanitizedEvent.id)
          .set(sanitizedEvent.toMap());
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  // Update an existing event
  Future<void> updateEvent(CalendarEventModel event) async {
    try {
      final updatedEvent = _applyVisibilityRules(
        event,
      ).copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_collection)
          .doc(event.id)
          .update(updatedEvent.toMap());
    } catch (e) {
      print('Error updating event: $e');
      rethrow;
    }
  }

  // Delete an event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection(_collection).doc(eventId).delete();
    } catch (e) {
      print('Error deleting event: $e');
      rethrow;
    }
  }

  // Stream events for real-time updates
  Stream<List<CalendarEventModel>> streamEventsForUser(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    CalendarEventModel.fromMap(doc.data(), documentId: doc.id),
              )
              .toList(),
        );
  }

  // Stream events for a specific month
  Stream<List<CalendarEventModel>> streamEventsForMonth(
    String userId,
    int year,
    int month,
  ) {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59);

    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
        .orderBy('date', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) =>
                    CalendarEventModel.fromMap(doc.data(), documentId: doc.id),
              )
              .toList(),
        );
  }
}
