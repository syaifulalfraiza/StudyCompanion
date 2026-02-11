import 'package:cloud_firestore/cloud_firestore.dart';

class ParentCalendarService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'parent_calendar_events';

  static Stream<List<Map<String, dynamic>>> streamParentEvents({
    required String parentId,
  }) {
    return _firestore
        .collection(_collectionName)
        .where('parentId', isEqualTo: parentId)
        .orderBy('date', descending: false)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        DateTime date = DateTime.now();
        
        // Handle date field - could be Timestamp or DateTime
        final dateField = data['date'];
        if (dateField is Timestamp) {
          date = dateField.toDate();
        } else if (dateField is DateTime) {
          date = dateField;
        }

        return {
          'id': doc.id,
          'parentId': data['parentId'] ?? parentId,
          'title': data['title'] ?? '',
          'time': data['time'] ?? '',
          'type': data['type'] ?? 'school_event',
          'description': data['description'] ?? '',
          'childName': data['childName'],
          'date': date,
        };
      }).toList();
    });
  }

  static Future<void> createEvent({
    required String parentId,
    required String title,
    required String time,
    required String type,
    required DateTime date,
    String? description,
    String? childName,
  }) async {
    final docRef = _firestore.collection(_collectionName).doc();
    await docRef.set({
      'parentId': parentId,
      'title': title,
      'time': time,
      'type': type,
      'description': description ?? '',
      'childName': childName,
      'date': Timestamp.fromDate(date),
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
  }) async {
    await _firestore.collection(_collectionName).doc(eventId).update({
      'title': title,
      'time': time,
      'type': type,
      'description': description ?? '',
      'childName': childName,
      'date': Timestamp.fromDate(date),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> deleteEvent(String eventId) async {
    await _firestore.collection(_collectionName).doc(eventId).delete();
  }
}
