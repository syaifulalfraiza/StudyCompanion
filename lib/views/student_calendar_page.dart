import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentCalendarPage extends StatefulWidget {
  const StudentCalendarPage({super.key});

  @override
  State<StudentCalendarPage> createState() => _StudentCalendarPageState();
}

class _StudentCalendarPageState extends State<StudentCalendarPage> {
  static const primary = Color(0xFF800000);
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();

  // Sample events data
  final Map<DateTime, List<Map<String, dynamic>>> _events = {
    DateTime(2026, 2, 10): [
      {'id': 'e1', 'title': 'Math Quiz', 'time': '10:00 AM', 'type': 'exam'},
      {
        'id': 'e2',
        'title': 'Science Lab Report Due',
        'time': '3:00 PM',
        'type': 'deadline'
      },
    ],
    DateTime(2026, 2, 11): [
      {
        'id': 'e3',
        'title': 'English Presentation',
        'time': '9:30 AM',
        'type': 'event'
      },
    ],
    DateTime(2026, 2, 13): [
      {
        'id': 'e4',
        'title': 'History Essay Due',
        'time': '11:59 PM',
        'type': 'deadline'
      },
    ],
    DateTime(2026, 2, 15): [
      {'id': 'e5', 'title': 'Science Fair', 'time': 'All Day', 'type': 'event'},
      {
        'id': 'e6',
        'title': 'Parent-Teacher Meeting',
        'time': '2:00 PM',
        'type': 'event'
      },
    ],
    DateTime(2026, 2, 17): [
      {
        'id': 'e7',
        'title': 'Midterm Exam - Math',
        'time': '8:00 AM',
        'type': 'exam'
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          _focusedMonth = DateTime(
                            _focusedMonth.year,
                            _focusedMonth.month + 1,
                          );
                        });
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
            child: ListView(
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
                }).toList(),
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
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final startingWeekday = firstDayOfMonth.weekday % 7;

    return Column(
      children: [
        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => SizedBox(
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
                  ))
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

            final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
            final isSelected = _isSameDay(date, _selectedDate);
            final isToday = _isSameDay(date, DateTime.now());
            final hasEvents = _events.containsKey(DateTime(date.year, date.month, date.day));

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
                          fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
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

  Widget _buildEventCard(Map<String, dynamic> event, DateTime date) {
    Color eventColor;
    IconData eventIcon;

    switch (event['type']) {
      case 'exam':
        eventColor = Colors.red;
        eventIcon = Icons.quiz;
        break;
      case 'deadline':
        eventColor = Colors.orange;
        eventIcon = Icons.assignment_late;
        break;
      case 'event':
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
                        event['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            event['time'],
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

  List<Map<String, dynamic>> _getEventsForDate(DateTime date) {
    final key = DateTime(date.year, date.month, date.day);
    return _events[key] ?? [];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showAddOrEditEventDialog({
    required DateTime date,
    Map<String, dynamic>? event,
  }) {
    final titleController = TextEditingController(text: event?['title'] ?? '');
    final timeController = TextEditingController(text: event?['time'] ?? '');
    String selectedType = event?['type'] ?? 'event';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event == null ? 'Add Event' : 'Edit Event'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: const [
                  DropdownMenuItem(value: 'event', child: Text('Event')),
                  DropdownMenuItem(value: 'exam', child: Text('Exam')),
                  DropdownMenuItem(value: 'deadline', child: Text('Deadline')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    selectedType = value;
                  }
                },
                decoration: const InputDecoration(labelText: 'Type'),
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
            onPressed: () {
              final title = titleController.text.trim();
              final time = timeController.text.trim();
              if (title.isEmpty || time.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields.')),
                );
                return;
              }
              final eventData = {
                'id': event?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
                'title': title,
                'time': time,
                'type': selectedType,
              };
              if (event == null) {
                _addEvent(date, eventData);
              } else {
                _updateEvent(date, eventData);
              }
              Navigator.pop(context);
            },
            child: Text(event == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _showEventDetails(Map<String, dynamic> event, DateTime date) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Time: ${event['time']}'),
            const SizedBox(height: 8),
            Text('Type: ${event['type']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddOrEditEventDialog(date: date, event: event);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () {
              _deleteEvent(date, event['id']);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addEvent(DateTime date, Map<String, dynamic> event) {
    final key = DateTime(date.year, date.month, date.day);
    setState(() {
      _events.putIfAbsent(key, () => []);
      _events[key]!.add(event);
    });
  }

  void _updateEvent(DateTime date, Map<String, dynamic> updatedEvent) {
    final key = DateTime(date.year, date.month, date.day);
    final list = _events[key];
    if (list == null) return;
    final index = list.indexWhere((e) => e['id'] == updatedEvent['id']);
    if (index == -1) return;
    setState(() {
      list[index] = updatedEvent;
    });
  }

  void _deleteEvent(DateTime date, String id) {
    final key = DateTime(date.year, date.month, date.day);
    final list = _events[key];
    if (list == null) return;
    setState(() {
      list.removeWhere((e) => e['id'] == id);
      if (list.isEmpty) {
        _events.remove(key);
      }
    });
  }
}
