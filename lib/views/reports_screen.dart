import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

/// Model for report generation
class ReportConfig {
  final String title;
  final String type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? role;

  ReportConfig({
    required this.title,
    required this.type,
    this.startDate,
    this.endDate,
    this.role,
  });
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  static const primary = Color(0xFF800000);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Generate Reports',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, primary.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.assessment, color: Colors.white, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'Analytics & Reports',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Generate comprehensive reports for your school',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Report Cards Grid
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildReportCard(
                          'User Statistics',
                          'Complete breakdown of all users',
                          Icons.people,
                          Colors.blue,
                          () => _generateUserReport(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildReportCard(
                          'Student Report',
                          'Student enrollment and activity',
                          Icons.school,
                          Colors.green,
                          () => _generateStudentReport(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReportCard(
                          'Teacher Report',
                          'Teacher assignments and classes',
                          Icons.history_edu,
                          Colors.teal,
                          () => _generateTeacherReport(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildReportCard(
                          'Parent Report',
                          'Parent engagement overview',
                          Icons.family_restroom,
                          Colors.orange,
                          () => _generateParentReport(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildReportCard(
                          'Class Report',
                          'All classes and subjects',
                          Icons.class_,
                          Colors.purple,
                          () => _generateClassReport(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildReportCard(
                          'Activity Report',
                          'System-wide activity logs',
                          Icons.timeline,
                          Colors.red,
                          () => _generateActivityReport(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFullWidthReportCard(
                    'Custom Report',
                    'Create a custom report with specific criteria',
                    Icons.tune,
                    Colors.indigo,
                    () => _showCustomReportDialog(),
                  ),
                ],
              ),
            ),

            // Quick Stats
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.bar_chart, color: primary),
                          SizedBox(width: 8),
                          Text(
                            'Quick Statistics',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getQuickStats(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final stats = snapshot.data!;
                          return Column(
                            children: [
                              _buildStatRow(
                                'Total Users',
                                stats['totalUsers'].toString(),
                                Icons.people,
                              ),
                              const Divider(),
                              _buildStatRow(
                                'Total Classes',
                                stats['totalClasses'].toString(),
                                Icons.class_,
                              ),
                              const Divider(),
                              _buildStatRow(
                                'Active Tasks',
                                stats['activeTasks'].toString(),
                                Icons.assignment,
                              ),
                              const Divider(),
                              _buildStatRow(
                                'Recent Events',
                                stats['recentEvents'].toString(),
                                Icons.event,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: _isGenerating ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          height: 160,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text(
                    'Generate →',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthReportCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: _isGenerating ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _getQuickStats() async {
    try {
      final users = await _firestore.collection('users').get();
      final classes = await _firestore.collection('classes').get();
      final tasks = await _firestore.collection('tasks').get();
      final events = await _firestore.collection('calendar_events').get();

      return {
        'totalUsers': users.docs.length,
        'totalClasses': classes.docs.length,
        'activeTasks': tasks.docs.length,
        'recentEvents': events.docs.length,
      };
    } catch (e) {
      print('Error getting quick stats: $e');
      return {
        'totalUsers': 0,
        'totalClasses': 0,
        'activeTasks': 0,
        'recentEvents': 0,
      };
    }
  }

  Future<void> _showPdfPreview(pw.Document pdf, String title) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: primary,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  await Printing.sharePdf(
                    bytes: await pdf.save(),
                    filename: '${title.replaceAll(' ', '_')}.pdf',
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.print),
                onPressed: () async {
                  await Printing.layoutPdf(
                    onLayout: (PdfPageFormat format) async => pdf.save(),
                  );
                },
              ),
            ],
          ),
          body: PdfPreview(
            build: (format) => pdf.save(),
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
            actions: const [],
          ),
        ),
      ),
    );
  }

  Future<void> _generateUserReport() async {
    setState(() => _isGenerating = true);

    try {
      final users = await _firestore.collection('users').get();

      final pdf = pw.Document();

      // Count by role
      final roleCounts = <String, int>{};
      final activeCount = users.docs
          .where((d) => d.data()['isActive'] == true)
          .length;

      for (var doc in users.docs) {
        final role = (doc.data()['role'] ?? 'unknown').toString();
        roleCounts[role] = (roleCounts[role] ?? 0) + 1;
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'User Statistics Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated on ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                pw.Text(
                  'Overview',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text('Total Users: ${users.docs.length}'),
                pw.Text('Active Users: $activeCount'),
                pw.Text('Inactive Users: ${users.docs.length - activeCount}'),

                pw.SizedBox(height: 20),
                pw.Text(
                  'Users by Role',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                ...roleCounts.entries.map(
                  (entry) =>
                      pw.Text('${entry.key.toUpperCase()}: ${entry.value}'),
                ),

                pw.SizedBox(height: 20),
                pw.Text(
                  'User Details',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),

                pw.Table.fromTextArray(
                  headers: ['Name', 'Email', 'Role', 'Status'],
                  data: users.docs.map((doc) {
                    final data = doc.data();
                    return [
                      data['name'] ?? '',
                      data['email'] ?? '',
                      (data['role'] ?? '').toString().toUpperCase(),
                      (data['isActive'] ?? true) ? 'Active' : 'Inactive',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
              ],
            );
          },
        ),
      );

      await _showPdfPreview(pdf, 'User Statistics Report');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User report generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateStudentReport() async {
    setState(() => _isGenerating = true);

    try {
      final students = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Student Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated on ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                pw.Text(
                  'Total Students: ${students.docs.length}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.Table.fromTextArray(
                  headers: ['Name', 'Email', 'Phone', 'Status'],
                  data: students.docs.map((doc) {
                    final data = doc.data();
                    return [
                      data['name'] ?? '',
                      data['email'] ?? '',
                      data['phone'] ?? 'N/A',
                      (data['isActive'] ?? true) ? 'Active' : 'Inactive',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
              ],
            );
          },
        ),
      );

      await _showPdfPreview(pdf, 'Student Report');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student report generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateTeacherReport() async {
    setState(() => _isGenerating = true);

    try {
      final teachers = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'teacher')
          .get();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Teacher Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated on ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                pw.Text(
                  'Total Teachers: ${teachers.docs.length}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.Table.fromTextArray(
                  headers: ['Name', 'Email', 'Phone', 'Status'],
                  data: teachers.docs.map((doc) {
                    final data = doc.data();
                    return [
                      data['name'] ?? '',
                      data['email'] ?? '',
                      data['phone'] ?? 'N/A',
                      (data['isActive'] ?? true) ? 'Active' : 'Inactive',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
              ],
            );
          },
        ),
      );

      await _showPdfPreview(pdf, 'Teacher Report');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teacher report generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateParentReport() async {
    setState(() => _isGenerating = true);

    try {
      final parents = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'parent')
          .get();

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Parent Engagement Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated on ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                pw.Text(
                  'Total Parents: ${parents.docs.length}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                pw.Table.fromTextArray(
                  headers: ['Name', 'Email', 'Phone', 'Status'],
                  data: parents.docs.map((doc) {
                    final data = doc.data();
                    return [
                      data['name'] ?? '',
                      data['email'] ?? '',
                      data['phone'] ?? 'N/A',
                      (data['isActive'] ?? true) ? 'Active' : 'Inactive',
                    ];
                  }).toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  cellAlignment: pw.Alignment.centerLeft,
                ),
              ],
            );
          },
        ),
      );

      await _showPdfPreview(pdf, 'Parent Engagement Report');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Parent report generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateClassReport() async {
    setState(() => _isGenerating = true);

    try {
      final classes = await _firestore.collection('classes').get();
      
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Class Overview Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated on ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                   color: PdfColors.grey700,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                pw.Text(
                  'Total Classes: ${classes.docs.length}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),

                if (classes.docs.isEmpty)
                  pw.Text(
                    'No classes found in the system.',
                    style: const pw.TextStyle(
                      fontSize: 14,
                      color: PdfColors.grey700,
                    ),
                  )
                else
                  pw.Table.fromTextArray(
                    headers: ['Class Name', 'Subject', 'Teacher', 'Students'],
                    data: classes.docs.map((doc) {
                      final data = doc.data();
                      return [
                        data['className'] ?? data['name'] ?? 'N/A',
                        data['subject'] ?? 'N/A',
                        data['teacherName'] ?? 'N/A',
                        (data['studentCount'] ?? 0).toString(),
                      ];
                    }).toList(),
                    headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    cellAlignment: pw.Alignment.centerLeft,
                  ),
              ],
            );
          },
        ),
      );

      await _showPdfPreview(pdf, 'Class Overview Report');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Class report generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateActivityReport() async {
    setState(() => _isGenerating = true);

    try {
      final tasks = await _firestore.collection('tasks').get();
      final announcements = await _firestore.collection('announcements').get();
      final events = await _firestore.collection('calendar_events').get();
      
      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'System Activity Report',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  'Generated on ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}',
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                pw.Text(
                  'Activity Summary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(
                          tasks.docs.length.toString(),
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue,
                          ),
                        ),
                        pw.Text('Total Tasks'),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          announcements.docs.length.toString(),
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green,
                          ),
                        ),
                        pw.Text('Announcements'),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          events.docs.length.toString(),
                          style: pw.TextStyle(
                            fontSize: 32,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.orange,
                          ),
                        ),
                        pw.Text('Events'),
                      ],
                    ),
                  ],
                ),
                
                pw.SizedBox(height: 30),
                pw.Text(
                  'Recent Tasks',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 12),
                if (tasks.docs.isEmpty)
                  pw.Text('No tasks found.')
                else
                  ...tasks.docs.take(5).map((doc) {
                    final data = doc.data();
                    return pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 8),
                      child: pw.Row(
                        children: [
                          pw.Container(
                            width: 8,
                            height: 8,
                            decoration: const pw.BoxDecoration(
                              color: PdfColors.blue,
                              shape: pw.BoxShape.circle,
                            ),
                          ),
                          pw.SizedBox(width: 8),
                          pw.Expanded(
                            child: pw.Text(
                              data['title'] ?? 'Untitled Task',
                              style: const pw.TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      );

      await _showPdfPreview(pdf, 'System Activity Report');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Activity report generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating report: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _showCustomReportDialog() {
    _showComingSoon('Custom report builder will be available soon');
  }

  void _showComingSoon(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.info_outline, color: primary),
            SizedBox(width: 12),
            Text('Coming Soon'),
          ],
        ),
        content: Text(message),
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
