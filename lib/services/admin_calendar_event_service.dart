import '../models/calendar_event_model.dart';
import '../services/firestore_calendar_event_service.dart';
import '../services/parent_calendar_service.dart';

class AdminCalendarEventService {
  final FirestoreCalendarEventService _calendarService =
      FirestoreCalendarEventService();

  Future<void> createAdminEvent({
    required String adminUserId,
    required String title,
    required String description,
    required DateTime dateTime,
    required EventType type,
    String visibilityScope = 'global',
    List<String> allowedRoles = const [],
    List<String> audienceUserIds = const [],
  }) async {
    final effectiveAudience =
        (visibilityScope == 'private' && audienceUserIds.isEmpty)
        ? [adminUserId]
        : audienceUserIds;

    final event = CalendarEventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: dateTime,
      type: type,
      visibilityScope: visibilityScope,
      allowedRoles: allowedRoles,
      audienceUserIds: effectiveAudience,
      createdByUserId: adminUserId,
      createdByRole: 'admin',
      createdAt: DateTime.now(),
    );

    await _calendarService.createEvent(event);

    final timeString = _formatTime(dateTime);

    await ParentCalendarService.createEvent(
      parentId: adminUserId,
      title: title,
      time: timeString,
      type: type.toString().split('.').last,
      date: dateTime,
      description: description,
      visibilityScope: visibilityScope,
      allowedRoles: allowedRoles,
      audienceUserIds: effectiveAudience,
      createdByUserId: adminUserId,
      createdByRole: 'admin',
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
