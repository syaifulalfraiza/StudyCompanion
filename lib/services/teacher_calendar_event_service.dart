import '../models/calendar_event_model.dart';
import '../services/firestore_calendar_event_service.dart';

class TeacherCalendarEventService {
  final FirestoreCalendarEventService _calendarService =
      FirestoreCalendarEventService();

  Future<void> createTeacherBroadcastEvent({
    required String teacherUserId,
    required String title,
    required String description,
    required DateTime dateTime,
    required EventType type,
  }) async {
    final event = CalendarEventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: dateTime,
      type: type,
      visibilityScope: 'role',
      allowedRoles: const ['student'],
      audienceUserIds: const [],
      createdByUserId: teacherUserId,
      createdByRole: 'teacher',
      createdAt: DateTime.now(),
    );

    await _calendarService.createEvent(event);
  }
}
