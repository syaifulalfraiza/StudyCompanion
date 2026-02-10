import 'package:flutter/material.dart';

class StudentClassesPage extends StatelessWidget {
  const StudentClassesPage({super.key});

  static const primary = Color(0xFF800000);

  @override
  Widget build(BuildContext context) {
    // Sample classes data
    final classes = [
      {
        'subject': 'Mathematics',
        'teacher': 'Cikgu Ahmad',
        'room': 'Room 101',
        'schedule': 'Mon, Wed, Fri • 8:00 AM',
        'color': Colors.blue,
      },
      {
        'subject': 'English',
        'teacher': 'Cikgu Suhana',
        'room': 'Room 203',
        'schedule': 'Tue, Thu • 9:30 AM',
        'color': Colors.green,
      },
      {
        'subject': 'Science',
        'teacher': 'Cikgu Ravi',
        'room': 'Lab 1',
        'schedule': 'Mon, Wed • 10:30 AM',
        'color': Colors.orange,
      },
      {
        'subject': 'History',
        'teacher': 'Cikgu Mei Ling',
        'room': 'Room 305',
        'schedule': 'Tue, Fri • 11:00 AM',
        'color': Colors.brown,
      },
      {
        'subject': 'Bahasa Melayu',
        'teacher': 'Cikgu Farah',
        'room': 'Room 202',
        'schedule': 'Mon, Thu • 1:00 PM',
        'color': Colors.red,
      },
      {
        'subject': 'Islamic Studies',
        'teacher': 'Cikgu Zainul',
        'room': 'Room 104',
        'schedule': 'Wed, Fri • 2:00 PM',
        'color': Colors.teal,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: primary,
        elevation: 0,
        title: const Text(
          'My Classes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primary, primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Semester',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${classes.length} Classes Enrolled',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Classes List
          const Text(
            'All Classes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          ...classes.map((classData) {
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
              child: InkWell(
                onTap: () {
                  // Navigate to class details
                  _showClassDetails(context, classData);
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Color indicator
                      Container(
                        width: 4,
                        height: 60,
                        decoration: BoxDecoration(
                          color: classData['color'] as Color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Class info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classData['subject'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  classData['teacher'] as String,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  classData['room'] as String,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.schedule,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    classData['schedule'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Arrow icon
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _showClassDetails(BuildContext context, Map<String, dynamic> classData) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 40,
                  decoration: BoxDecoration(
                    color: classData['color'] as Color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  classData['subject'] as String,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildDetailRow(Icons.person, 'Teacher', classData['teacher'] as String),
            _buildDetailRow(Icons.location_on, 'Room', classData['room'] as String),
            _buildDetailRow(Icons.schedule, 'Schedule', classData['schedule'] as String),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showComingSoonDialog(
                        context,
                        'Materials',
                        classData['subject'] as String,
                      );
                    },
                    icon: const Icon(Icons.book),
                    label: const Text('Materials'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showComingSoonDialog(
                        context,
                        'Assignments',
                        classData['subject'] as String,
                      );
                    },
                    icon: const Icon(Icons.assignment),
                    label: const Text('Assignments'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primary,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(
    BuildContext context,
    String feature,
    String subject,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature - Coming Soon'),
        content: Text(
          '$feature for $subject will be available in a future update.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
