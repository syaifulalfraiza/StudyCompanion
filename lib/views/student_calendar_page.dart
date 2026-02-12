import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event_model.dart';
import '../services/firestore_calendar_event_service.dart';
import '../core/user_session.dart';

class StudentCalendarPage extends StatefulWidget {
  const StudentCalendarPage({super.key});

  @override
  State<StudentCalendarPage> createState() => _StudentCalendarPageState();
}

class _StudentCalendarPageState extends State<StudentCalendarPage> {
  static const primary = Color(0xFF800000);
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  final FirestoreCalendarEventService _calendarService =
      FirestoreCalendarEventService();
  List<CalendarEventModel> _allEvents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);

    try {
      final userId = UserSession.userId;
      final events = await _calendarService.getEventsForMonth(
        userId,
        _focusedMonth.year,
        _focusedMonth.month,
        role: UserSession.role,
      );
      setState(() {
        _allEvents = events;
      });
    } catch (e) {
      print('Error loading events: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Map<DateTime, List<CalendarEventModel>> _groupEventsByDate() {
    final Map<DateTime, List<CalendarEventModel>> grouped = {};

    for (var event in _allEvents) {
      final dateKey = DateTime(
        event.date.year,
        event.date.month,
        event.date.day,
      );
      if (grouped[dateKey] == null) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(event);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
                _focusedMonth = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month - 1,
                          );
                        });
                        _loadEvents();
                      },
                    ),
                    Text(
                      DateFormat('MMMM yyyy').format(_focusedMonth),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month + 1,
                          );
                        });
                        _loadEvents();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildCalendarGrid(),
              ],
            ),
          ),

          // Events List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              _showAddOrEditEventDialog(date: _selectedDate);
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._getEventsForDate(_selectedDate).map((event) {
                        return _buildEventCard(event, _selectedDate);
                      }),
                      if (_getEventsForDate(_selectedDate).isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No events scheduled',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final daysInMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month + 1,
      0,
    ).day;
    final firstDayOfMonth = DateTime(
      _focusedMonth.year,
      _focusedMonth.month,
      1,
    );
    final startingWeekday = firstDayOfMonth.weekday % 7;
    final groupedEvents = _groupEventsByDate();

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (day) => SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      day,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 8),
        // Calendar days
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: 42,
          itemBuilder: (context, index) {
            final dayNumber = index - startingWeekday + 1;
            if (dayNumber < 1 || dayNumber > daysInMonth) {
              return const SizedBox();
            }

            final date = DateTime(
              _focusedMonth.year,
              _focusedMonth.month,
              dayNumber,
            );
            final isSelected = _isSameDay(date, _selectedDate);
            final isToday = _isSameDay(date, DateTime.now());
            final hasEvents = groupedEvents.containsKey(
              DateTime(date.year, date.month, date.day),
            );

            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedDate = date;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white
                      : isToday
                      ? Colors.white24
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        dayNumber.toString(),
                        style: TextStyle(
                          color: isSelected ? primary : Colors.white,
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (hasEvents)
                      Positioned(
                        bottom: 4,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected ? primary : Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventCard(CalendarEventModel event, DateTime date) {
    Color eventColor;
    IconData eventIcon;

    switch (event.type) {
      case EventType.exam:
        eventColor = Colors.red;
        eventIcon = Icons.quiz;
        break;
      case EventType.deadline:
        eventColor = Colors.orange;
        eventIcon = Icons.assignment_late;
        break;
      case EventType.meeting:
        eventColor = Colors.blue;
        eventIcon = Icons.people;
        break;
      case EventType.holiday:
        eventColor = Colors.purple;
        eventIcon = Icons.beach_access;
        break;
      case EventType.event:
        eventColor = Colors.blue;
        eventIcon = Icons.event;
        break;
      default:
        eventColor = Colors.grey;
        eventIcon = Icons.circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showEventDetails(event, date),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: eventColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(eventIcon, color: eventColor, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (event.description.isNotEmpty)
                        Text(
                          event.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('h:mm a').format(event.date),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<CalendarEventModel> _getEventsForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    final groupedEvents = _groupEventsByDate();
    return groupedEvents[key] ?? [];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showAddOrEditEventDialog({
    required DateTime date,
    CalendarEventModel? event,
  }) {
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(
      text: event?.description ?? '',
    );
    EventType selectedType = event?.type ?? EventType.event;
    DateTime selectedDateTime = event?.date ?? date;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(
      event?.date ?? DateTime.now(),
    );

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(event == null ? 'Add Event' : 'Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<EventType>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Event Type',
                    border: OutlineInputBorder(),
                  ),
                  items: EventType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(
                        type.toString().split('.').last.toUpperCase(),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat('MMM dd, yyyy').format(selectedDateTime),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setDialogState(() {
                        selectedDateTime = pickedDate;
                      });
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Time'),
                  subtitle: Text(selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (pickedTime != null) {
                      setDialogState(() {
                        selectedTime = pickedTime;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }

                final eventDateTime = DateTime(
                  selectedDateTime.year,
                  selectedDateTime.month,
                  selectedDateTime.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                final newEvent = CalendarEventModel(
                  id:
                      event?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  description: descriptionController.text,
                  date: eventDateTime,
                  type: selectedType,
                  userId: UserSession.userId,
                  visibilityScope: 'private',
                  audienceUserIds: [UserSession.userId],
                  createdByUserId: UserSession.userId,
                  createdByRole: UserSession.role,
                  createdAt: event?.createdAt ?? DateTime.now(),
                  updatedAt: event != null ? DateTime.now() : null,
                );

                try {
                  if (event == null) {
                    await _calendarService.createEvent(newEvent);
                  } else {
                    await _calendarService.updateEvent(newEvent);
                  }
                  Navigator.pop(context);
                  _loadEvents();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        event == null
                            ? 'Event created successfully'
                            : 'Event updated successfully',
                      ),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error saving event: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
              ),
              child: Text(event == null ? 'Add' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEventDetails(CalendarEventModel event, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description.isNotEmpty) ...[
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(event.description),
              const SizedBox(height: 8),
            ],
            Text('Time: ${DateFormat('h:mm a').format(event.date)}'),
            const SizedBox(height: 8),
            Text(
              'Type: ${event.type.toString().split('.').last.toUpperCase()}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              if (!_canModifyEvent(event)) {
                Navigator.pop(context);
                _showPermissionDenied();
                return;
              }
              Navigator.pop(context);
              _showAddOrEditEventDialog(date: date, event: event);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () async {
              if (!_canModifyEvent(event)) {
                Navigator.pop(context);
                _showPermissionDenied();
                return;
              }
              try {
                await _calendarService.deleteEvent(event.id);
                Navigator.pop(context);
                _loadEvents();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Event deleted successfully')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error deleting event: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  bool _canModifyEvent(CalendarEventModel event) {
    final userId = UserSession.userId;
    if (userId.isEmpty) return false;
    if (event.visibilityScope != 'private') return false;

    if (event.createdByUserId == userId) return true;
    if (event.userId == userId) return true;
    if (event.audienceUserIds.contains(userId)) return true;

    return false;
  }

  void _showPermissionDenied() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You can only edit or delete your private reminders.'),
      ),
    );
  }
}
