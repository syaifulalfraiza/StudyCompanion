# Calendar Events Firestore Migration

## Overview
Calendar events have been migrated from hardcoded sample data to Firestore database storage, enabling persistent, user-specific event management across both Teacher and Student modules.

## Changes Made

### 1. New Data Model
**File**: `lib/models/calendar_event_model.dart`
- Created `CalendarEventModel` class with full CRUD support
- Enum `EventType`: exam, deadline, event, holiday, meeting, other
- Fields: id, title, description, date, type, userId, classroomId, subjectId, timestamps
- Firestore serialization methods: `toMap()` and `fromMap()`

### 2. Firestore Service
**File**: `lib/services/firestore_calendar_event_service.dart`
- Collection: `calendar_events`
- **Methods**:
  - `getEventsForUser(userId)` - Get all events for a user
  - `getEventsByDateRange(userId, startDate, endDate)` - Date range query
  - `getEventsForMonth(userId, year, month)` - Monthly events
  - `getEventsForClassroom(classroomId)` - Classroom-specific events
  - `createEvent(event)` - Create new event
  - `updateEvent(event)` - Update existing event
  - `deleteEvent(eventId)` - Delete event
  - `streamEventsForUser(userId)` - Real-time stream
  - `streamEventsForMonth(userId, year, month)` - Monthly stream

### 3. Teacher Calendar Page
**File**: `lib/views/teacher_calendar_page.dart`
- **Removed**: Hardcoded `Map<DateTime, List<Map<String, dynamic>>> _events`
- **Added**:
  - `FirestoreCalendarEventService _calendarService`
  - `List<CalendarEventModel> _allEvents`
  - `_loadEvents()` - Loads events from Firestore on init and month change
  - `_groupEventsByDate()` - Groups events by date for calendar display
- **Updated**:
  - Month navigation (chevron buttons) now reload events
  - Calendar grid uses `groupedEvents` from Firestore
  - Event cards display time from DateTime with DateFormat
  - Add Event dialog fully functional with date/time pickers
  - Support for all EventType values with appropriate icons

### 4. Student Calendar Page
**File**: `lib/views/student_calendar_page.dart`
- **Removed**: Hardcoded `Map<DateTime, List<Map<String, dynamic>>> _events`
- **Removed**: Local methods `_addEvent`, `_updateEvent`, `_deleteEvent`
- **Added**:
  - `FirestoreCalendarEventService _calendarService`
  - `List<CalendarEventModel> _allEvents`
  - `_loadEvents()` - Loads events from Firestore
  - `_groupEventsByDate()` - Groups events by date
  - Loading indicator while fetching events
- **Updated**:
  - `_getEventsForDate()` returns `List<CalendarEventModel>`
  - `_buildEventCard()` accepts `CalendarEventModel`
  - `_showAddOrEditEventDialog()` uses Firestore CRUD
  - `_showEventDetails()` uses Firestore delete
  - Month navigation reloads events

## How It Works

### Event Creation Flow
1. User taps FAB (+) button or "Add" button
2. Dialog opens with form fields (title, description, type, date, time)
3. User fills in details and taps "Add"
4. App creates `CalendarEventModel` with current `UserSession.userId`
5. Event saved to Firestore `calendar_events` collection
6. Events automatically reload
7. Calendar updates to show new event

### Event Display Flow
1. On page load, `initState()` calls `_loadEvents()`
2. Service fetches events for current month and userId
3. `_groupEventsByDate()` organizes events by date
4. Calendar grid shows dots for dates with events
5. Event list displays events for selected date
6. Loading indicator shown during fetch

### Event Edit/Delete Flow
1. User taps event card
2. Details dialog opens
3. "Edit" button opens edit dialog with pre-filled data
4. "Delete" button removes event from Firestore
5. Events reload after edit/delete

## Database Structure

### Firestore Collection: `calendar_events`
```
calendar_events/
  {eventId}/
    - id: string
    - title: string
    - description: string
    - date: timestamp
    - type: string (enum value)
    - userId: string (teacher or student ID)
    - classroomId: string (optional)
    - subjectId: string (optional)
    - createdAt: timestamp
    - updatedAt: timestamp (nullable)
```

## Benefits

1. **Persistence**: Events persist across app restarts
2. **User-Specific**: Each user sees only their events
3. **Real-Time**: Support for real-time updates via streams
4. **Scalable**: Can handle unlimited events per user
5. **No Console Required**: Events created directly from app
6. **Production Ready**: No hardcoded data, fully database-driven

## Testing

### To Test Event Creation:
1. Login as teacher (ahmad@school.edu.my) or student
2. Navigate to Calendar page
3. Tap FAB (+) button
4. Fill in event details:
   - Title: "Test Event"
   - Description: "Testing Firestore integration"
   - Type: Choose any (exam, deadline, event, etc.)
   - Date: Select future date
   - Time: Select time
5. Tap "Add"
6. Event should appear on calendar
7. Restart app - event should persist

### To Verify Firestore:
1. Open Firebase Console
2. Navigate to Firestore Database
3. Look for `calendar_events` collection
4. Should see created events with all fields

## Future Enhancements (Optional)

1. **Recurring Events**: Add support for daily/weekly/monthly recurrence
2. **Reminders**: Push notifications before events
3. **Classroom Events**: Link events to specific classrooms/subjects
4. **Shared Events**: Share events between teachers and students
5. **Event Search**: Search events by title or type
6. **Export**: Export events to calendar apps
7. **Event Colors**: Custom color coding per event type

## Migration Status

✅ CalendarEventModel created
✅ FirestoreCalendarEventService implemented
✅ Teacher Calendar migrated
✅ Student Calendar migrated
✅ All CRUD operations functional
✅ No compile errors
✅ Files formatted

**Status**: Migration Complete - Ready for Testing
