class SampleParentCalendarData {
  /// Event type constants
  static const String eventTypeSchoolEvent = 'school_event';
  static const String eventTypeExamination = 'examination';
  static const String eventTypeDeadline = 'deadline';
  static const String eventTypeParentTeaching = 'parent_teaching';
  static const String eventTypeHoliday = 'holiday';
  static const String eventTypeReminder = 'reminder';

  /// Generate sample calendar events for parent dashboard
  static Map<DateTime, List<Map<String, dynamic>>> generateSampleEvents() {
    return {
      // February 2026 Events
      DateTime(2026, 2, 10): [
        {
          'id': 'e1',
          'title': 'Mathematics Quiz - Form 1A',
          'time': '10:00 AM',
          'type': eventTypeExamination,
          'description': 'Form 1A Mathematics quiz covering algebra and geometry',
          'childName': 'Amir Abdullah',
        },
        {
          'id': 'e2',
          'title': 'Science Lab Report Due',
          'time': '3:00 PM',
          'type': eventTypeDeadline,
          'description': 'Science: Photosynthesis lab report submission',
          'childName': 'Amir Abdullah',
        },
      ],
      DateTime(2026, 2, 12): [
        {
          'id': 'e3',
          'title': 'Mathematics Competition Registration Closes',
          'time': '5:00 PM',
          'type': eventTypeReminder,
          'description': 'Last day to register for National Mathematics Competition',
          'childName': 'Multiple',
        },
      ],
      DateTime(2026, 2, 13): [
        {
          'id': 'e4',
          'title': 'History Essay Due',
          'time': '11:59 PM',
          'type': eventTypeDeadline,
          'description': 'History: Essay on "The Impact of Colonization" - 5 pages',
          'childName': 'Muhammad Azhar',
        },
      ],
      DateTime(2026, 2, 15): [
        {
          'id': 'e5',
          'title': 'School Sports Day',
          'time': 'All Day',
          'type': eventTypeSchoolEvent,
          'description': 'Annual Sports Day at school field. All students must participate.',
          'childName': 'All Students',
        },
      ],
      DateTime(2026, 2, 17): [
        {
          'id': 'e6',
          'title': 'Biology Quiz - Form 2B',
          'time': '8:00 AM',
          'type': eventTypeExamination,
          'description': 'Biology: Cell Structure and Functions quiz',
          'childName': 'Muhammad Azhar',
        },
      ],
      DateTime(2026, 2, 18): [
        {
          'id': 'e7',
          'title': 'Science Fair - Form 1C',
          'time': '2:00 PM',
          'type': eventTypeSchoolEvent,
          'description': 'Form 1C Science Fair - Students present their projects',
          'childName': 'Siti Mariah',
        },
      ],
      DateTime(2026, 2, 20): [
        {
          'id': 'e8',
          'title': 'Parent-Teacher Meeting',
          'time': '2:00 PM - 5:00 PM',
          'type': eventTypeParentTeaching,
          'description': 'Annual Parent-Teacher Meeting. Discuss academic progress with teachers.',
          'childName': 'All Students',
        },
      ],
      DateTime(2026, 2, 22): [
        {
          'id': 'e9',
          'title': 'English Story Telling Competition',
          'time': '3:30 PM',
          'type': eventTypeSchoolEvent,
          'description': 'English Club Story Telling Competition - Preliminary round. Cash prizes available.',
          'childName': 'Form 1-3 Students',
        },
      ],

      // March 2026 Events
      DateTime(2026, 3, 1): [
        {
          'id': 'e10',
          'title': 'Mid-Year Examinations Begin',
          'time': '8:00 AM',
          'type': eventTypeExamination,
          'description': 'Mid-Year Examination period starts for Form 1-3 (Dates: March 1-20)',
          'childName': 'All Students',
        },
      ],
      DateTime(2026, 3, 5): [
        {
          'id': 'e11',
          'title': 'Mathematics Exam - Form 1',
          'time': '9:00 AM - 11:00 AM',
          'type': eventTypeExamination,
          'description': 'Mathematics Paper 1 (2 hours) - Form 1 students',
          'childName': 'Amir Abdullah, Siti Mariah',
        },
        {
          'id': 'e12',
          'title': 'English Exam - Form 2',
          'time': '2:00 PM - 4:00 PM',
          'type': eventTypeExamination,
          'description': 'English Paper 1 (2 hours) - Form 2 students',
          'childName': 'Muhammad Azhar, Lim Wei Chen',
        },
      ],
      DateTime(2026, 3, 10): [
        {
          'id': 'e13',
          'title': 'Science Exam - Form 1 & 2',
          'time': '8:30 AM - 10:30 AM',
          'type': eventTypeExamination,
          'description': 'Science exam covering Physics, Chemistry, Biology (2 hours)',
          'childName': 'Amir Abdullah, Siti Mariah, Muhammad Azhar, Lim Wei Chen',
        },
      ],
      DateTime(2026, 3, 15): [
        {
          'id': 'e14',
          'title': 'Mathematics Competition',
          'time': '9:00 AM',
          'type': eventTypeSchoolEvent,
          'description': 'National Mathematics Competition - Regional Finals',
          'childName': 'Selected Students',
        },
      ],
      DateTime(2026, 3, 20): [
        {
          'id': 'e15',
          'title': 'Mid-Year Examinations End',
          'time': '11:00 AM',
          'type': eventTypeExamination,
          'description': 'Last day of Mid-Year Examination period',
          'childName': 'All Students',
        },
      ],

      // April 2026 Events
      DateTime(2026, 4, 1): [
        {
          'id': 'e16',
          'title': 'School Holiday Break',
          'time': 'All Day',
          'type': eventTypeHoliday,
          'description': 'School holidays begin - 2 weeks break',
          'childName': 'All Students',
        },
      ],
      DateTime(2026, 4, 15): [
        {
          'id': 'e17',
          'title': 'School Reopens',
          'time': '8:00 AM',
          'type': eventTypeSchoolEvent,
          'description': 'Classes resume after holiday break',
          'childName': 'All Students',
        },
      ],
    };
  }

  /// Get events for a specific date
  static List<Map<String, dynamic>> getEventsForDate(DateTime date) {
    final events = generateSampleEvents();
    final normalizedDate = DateTime(date.year, date.month, date.day);

    return events[normalizedDate] ?? [];
  }

  /// Get all events for a month
  static List<Map<String, dynamic>> getEventsForMonth(int month, int year) {
    final events = generateSampleEvents();
    final monthEvents = <Map<String, dynamic>>[];

    events.forEach((date, eventList) {
      if (date.month == month && date.year == year) {
        monthEvents.addAll(eventList);
      }
    });

    return monthEvents;
  }

  /// Get upcoming events (next 7 days)
  static List<Map<String, dynamic>> getUpcomingEvents() {
    final events = generateSampleEvents();
    final now = DateTime.now();
    final nextWeek = now.add(const Duration(days: 7));
    final upcoming = <Map<String, dynamic>>[];

    events.forEach((date, eventList) {
      if (date.isAfter(now) && date.isBefore(nextWeek)) {
        upcoming.addAll(eventList);
      }
    });

    // Sort by date
    upcoming.sort((a, b) {
      final dateA = events.entries
          .firstWhere((e) => e.value.contains(a))
          .key;
      final dateB = events.entries
          .firstWhere((e) => e.value.contains(b))
          .key;
      return dateA.compareTo(dateB);
    });

    return upcoming;
  }

  /// Get events by type
  static List<Map<String, dynamic>> getEventsByType(String eventType) {
    final events = generateSampleEvents();
    final filtered = <Map<String, dynamic>>[];

    events.forEach((date, eventList) {
      for (var event in eventList) {
        if (event['type'] == eventType) {
          filtered.add(event);
        }
      }
    });

    return filtered;
  }

  /// Get important dates (examinations and parent-teacher meetings)
  static List<Map<String, dynamic>> getImportantDates() {
    final events = generateSampleEvents();
    final important = <Map<String, dynamic>>[];

    events.forEach((date, eventList) {
      for (var event in eventList) {
        if (event['type'] == eventTypeExamination ||
            event['type'] == eventTypeParentTeaching) {
          important.add({
            ...event,
            'date': date,
          });
        }
      }
    });

    // Sort by date
    important.sort((a, b) {
      final dateA = a['date'] as DateTime;
      final dateB = b['date'] as DateTime;
      return dateA.compareTo(dateB);
    });

    return important;
  }

  /// Get color for event type
  static int getColorForEventType(String eventType) {
    switch (eventType) {
      case eventTypeExamination:
        return 0xFFD32F2F; // Red
      case eventTypeDeadline:
        return 0xFFF57C00; // Orange
      case eventTypeParentTeaching:
        return 0xFF0288D1; // Blue
      case eventTypeSchoolEvent:
        return 0xFF388E3C; // Green
      case eventTypeHoliday:
        return 0xFF7B1FA2; // Purple
      case eventTypeReminder:
        return 0xFFFFB300; // Amber
      default:
        return 0xFF757575; // Grey
    }
  }

  /// Get icon for event type
  static String getIconForEventType(String eventType) {
    switch (eventType) {
      case eventTypeExamination:
        return '📝';
      case eventTypeDeadline:
        return '⏰';
      case eventTypeParentTeaching:
        return '👨‍🏫';
      case eventTypeSchoolEvent:
        return '🎓';
      case eventTypeHoliday:
        return '🎉';
      case eventTypeReminder:
        return '⚠️';
      default:
        return '📌';
    }
  }
}
