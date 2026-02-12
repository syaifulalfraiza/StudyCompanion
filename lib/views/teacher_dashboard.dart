import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studycompanion_app/models/class_model.dart';
import 'package:studycompanion_app/viewmodels/teacher_dashboard_viewmodel.dart';
import 'package:studycompanion_app/core/user_session.dart';
import 'package:studycompanion_app/views/teacher_assignments_page.dart';
import 'package:studycompanion_app/views/teacher_announcements_page.dart';

Widget sectionTitle(String text) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  child: Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  ),
);

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  static const primary = Color(0xFF631018);

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = TeacherDashboardViewModel();
        viewModel.initializeTeacher(UserSession.userId ?? 't1');
        return viewModel;
      },
      child: Consumer<TeacherDashboardViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFFCF9F9),
            appBar: AppBar(
              backgroundColor: TeacherDashboard.primary,
              title: Text(viewModel.teacherName ?? 'Teacher Dashboard'),
              actions: [
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider.value(
                          value: viewModel,
                          child: const TeacherAnnouncementsPage(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.campaign),
                  tooltip: 'Announcements',
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider.value(
                          value: viewModel,
                          child: const TeacherAssignmentsPage(),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment),
                  tooltip: 'All Assignments',
                ),
                IconButton(
                  onPressed: () => _showAddClassDialog(context, viewModel),
                  icon: const Icon(Icons.add),
                  tooltip: 'Add Class',
                ),
                IconButton(
                  onPressed: () {
                    UserSession.logout();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddClassDialog(context, viewModel),
              backgroundColor: TeacherDashboard.primary,
              tooltip: 'Add Class',
              child: const Icon(Icons.add),
            ),
            body: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.classes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.class_, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text('No classes yet'),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () => _showAddClassDialog(context, viewModel),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Class'),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                children: [
                                  const Expanded(
                                    child: Text(
                                      'My Classes',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _showAddClassDialog(context, viewModel),
                                    icon: const Icon(Icons.add),
                                    label: const Text('Add Class'),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: viewModel.classes.map((classItem) {
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: ExpansionTile(
                                      title: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              classItem.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      subtitle: Text('${classItem.studentCount} student(s)'),
                                      trailing: PopupMenuButton<String>(
                                        onSelected: (String value) {
                                          if (value == 'delete') {
                                            _showDeleteConfirmation(context, viewModel, classItem.id);
                                          }
                                        },
                                        itemBuilder: (BuildContext context) => [
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          child: CombinationChart(
                                            days: ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
                                            assignments: _generateAssignmentData(classItem),
                                            submitted: _generateSubmissionData(classItem),
                                            totalStudents: classItem.studentCount,
                                            chartHeight: 80,
                                          ),
                                        ),
                                        const Divider(height: 1),
                                        ListTile(
                                          title: const Text(
                                            'Assignments',
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(
                                            '${viewModel.allAssignments.where((a) => a.classId == classItem.id).length} assignment(s)',
                                          ),
                                          trailing: const Icon(Icons.chevron_right),
                                          onTap: () {
                                            viewModel.selectClass(classItem.id);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChangeNotifierProvider.value(
                                                  value: viewModel,
                                                  child: const TeacherAssignmentsPage(),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }

  void _showAddClassDialog(BuildContext context, TeacherDashboardViewModel viewModel) {
    final nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Class'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: 'Class name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                // Add class logic would go here
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TeacherDashboardViewModel viewModel, String classId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class'),
        content: const Text('Are you sure you want to delete this class?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete class logic would go here
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<int> _generateAssignmentData(ClassModel classItem) {
    // Generate sample data for assignments per day
    return List.generate(7, (i) => (2 + (i % 3)));
  }

  List<int> _generateSubmissionData(ClassModel classItem) {
    // Generate sample submission data
    final students = classItem.studentCount;
    if (students == 0) return List.generate(7, (_) => 0);
    return List.generate(7, (i) => ((students * (0.5 + (i % 3) * 0.1)).toInt()).clamp(0, students));
  }
}

// Simple combination chart made from widgets (no external libs)
class CombinationChart extends StatelessWidget {
  final List<String> days;
  final List<int> assignments;
  final List<int> submitted;
  final int totalStudents;
  final double chartHeight;

  const CombinationChart({
    required this.days,
    required this.assignments,
    required this.submitted,
    required this.totalStudents,
    this.chartHeight = 120.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final maxAssignments = (assignments.isNotEmpty ? assignments.reduce((a, b) => a > b ? a : b) : 1);
    final maxValue = [maxAssignments, totalStudents].reduce((a, b) => a > b ? a : b).toDouble();
    final chartHeightLocal = chartHeight;

    return Column(
      children: [
        SizedBox(
          height: chartHeightLocal,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  CustomPaint(
                    size: Size(width, chartHeightLocal),
                    painter: _LinePainter(assignments: assignments, maxValue: maxValue, chartHeight: chartHeightLocal),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(days.length, (i) {
                      final submittedVal = submitted.length > i ? submitted[i].toDouble() : 0.0;
                      final notSubmittedVal = (totalStudents - submittedVal).clamp(0, totalStudents).toDouble();

                      final submittedHeight = (submittedVal / maxValue) * (chartHeight * 0.5);
                      final notSubmittedHeight = (notSubmittedVal / maxValue) * (chartHeight * 0.5);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(width: 22, height: submittedHeight + notSubmittedHeight, color: Colors.grey[300]),
                              Container(width: 22, height: submittedHeight, color: Colors.green),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(days[i], style: const TextStyle(fontSize: 12)),
                        ],
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            SizedBox(width: 8),
            Icon(Icons.stop, color: Colors.blueAccent, size: 12),
            SizedBox(width: 6),
            Text('Assignments'),
            SizedBox(width: 12),
            Icon(Icons.stop, color: Colors.green, size: 12),
            SizedBox(width: 6),
            Text('Submitted'),
            SizedBox(width: 12),
            Icon(Icons.stop, color: Colors.grey, size: 12),
            SizedBox(width: 6),
            Text('Not submitted'),
            SizedBox(width: 8),
          ],
        )
      ],
    );
  }
}

class _LinePainter extends CustomPainter {
  final List<int> assignments;
  final double maxValue;
  final double chartHeight;

  _LinePainter({required this.assignments, required this.maxValue, required this.chartHeight});

  @override
  void paint(Canvas canvas, Size size) {
    if (assignments.isEmpty) return;
    final paint = Paint()
      ..color = Colors.blueAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..isAntiAlias = true;

    final pointPaint = Paint()..color = Colors.blueAccent;

    final path = Path();
    final step = size.width / assignments.length;

    for (var i = 0; i < assignments.length; i++) {
      final x = step * (i + 0.5);
      final value = assignments[i].toDouble();
      final y = size.height - ((value / maxValue) * (size.height * 0.5)) - 8;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3.0, pointPaint);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// 🔹 QUICK ACTION
class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const QuickAction({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: TeacherDashboard.primary),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// 🔹 TASK CARD
class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double progress;
  const TaskCard(this.title, this.subtitle, this.progress, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            color: TeacherDashboard.primary,
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// 🔹 ANNOUNCEMENT
class AnnouncementTile extends StatelessWidget {
  final String title;
  const AnnouncementTile(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(title),
      ),
    );
  }
}
