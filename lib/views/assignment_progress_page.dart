import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studycompanion_app/viewmodels/teacher_dashboard_viewmodel.dart';
import 'package:studycompanion_app/models/assignment_model.dart';
import 'package:studycompanion_app/models/grade_model.dart';
import 'package:studycompanion_app/services/sample_teacher_data.dart';

class AssignmentProgressPage extends StatelessWidget {
  final String assignmentId;

  const AssignmentProgressPage({
    super.key,
    required this.assignmentId,
  });

  static const primary = Color(0xFF631018);

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherDashboardViewModel>(
      builder: (context, viewModel, _) {
        final progressData = viewModel.getAssignmentProgress(assignmentId);
        
        if (progressData.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Assignment Progress'),
              backgroundColor: primary,
            ),
            body: const Center(child: Text('Assignment not found')),
          );
        }

        final assignment = progressData['assignment'] as AssignmentModel;
        final grades = progressData['grades'] as List<GradeModel>;
        final totalStudents = progressData['totalStudents'] as int;
        final submittedCount = progressData['submittedCount'] as int;
        final gradedCount = progressData['gradedCount'] as int;
        final averageScore = progressData['averageScore'] as double?;

        // Get all students in the class
        final classModel = viewModel.getClassById(assignment.classId);
        final students = SampleTeacherData.getStudentsInClass(assignment.classId);

        return Scaffold(
          backgroundColor: const Color(0xFFFCF9F9),
          appBar: AppBar(
            title: const Text('Student Progress'),
            backgroundColor: primary,
          ),
          body: Column(
            children: [
              // Assignment Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${classModel?.name ?? 'Class'} - ${assignment.subject}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatBox(
                            'Submitted',
                            '$submittedCount/$totalStudents',
                            Icons.assignment_turned_in,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatBox(
                            'Graded',
                            '$gradedCount/$totalStudents',
                            Icons.grade,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatBox(
                            'Average',
                            averageScore != null ? '${averageScore.toStringAsFixed(1)}%' : 'N/A',
                            Icons.analytics,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Students List
              Expanded(
                child: students.isEmpty
                    ? const Center(child: Text('No students found'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final studentId = student['id'] as String;
                          final studentName = student['name'] as String;
                          final grade = viewModel.getGradeForStudent(assignmentId, studentId);
                          
                          // Simulate submission status (in real app, this would come from data)
                          final isSubmitted = index < submittedCount;

                          return _buildStudentCard(
                            context,
                            viewModel,
                            assignment,
                            studentId,
                            studentName,
                            isSubmitted,
                            grade,
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(
    BuildContext context,
    TeacherDashboardViewModel viewModel,
    AssignmentModel assignment,
    String studentId,
    String studentName,
    bool isSubmitted,
    GradeModel? grade,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Name & Status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: primary.withOpacity(0.1),
                  child: Text(
                    studentName[0].toUpperCase(),
                    style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isSubmitted ? Icons.check_circle : Icons.cancel,
                            size: 16,
                            color: isSubmitted ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isSubmitted ? 'Submitted' : 'Not Submitted',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSubmitted ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (grade != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getGradeColor(grade.grade).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getGradeColor(grade.grade),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          grade.grade,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _getGradeColor(grade.grade),
                          ),
                        ),
                        Text(
                          '${grade.percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 12,
                            color: _getGradeColor(grade.grade),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Feedback (if exists)
            if (grade?.feedback != null && grade!.feedback!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        grade.feedback!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (grade != null)
                  TextButton.icon(
                    onPressed: () => _showGradeDialog(
                      context,
                      viewModel,
                      assignment,
                      studentId,
                      studentName,
                      existingGrade: grade,
                    ),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Update Grade'),
                    style: TextButton.styleFrom(foregroundColor: Colors.blue),
                  )
                else if (isSubmitted)
                  ElevatedButton.icon(
                    onPressed: () => _showGradeDialog(
                      context,
                      viewModel,
                      assignment,
                      studentId,
                      studentName,
                    ),
                    icon: const Icon(Icons.grade, size: 18),
                    label: const Text('Record Grade'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.grade, size: 18),
                    label: const Text('Awaiting Submission'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getGradeColor(String gradeLetter) {
    switch (gradeLetter) {
      case 'A+':
      case 'A':
      case 'A-':
        return Colors.green;
      case 'B+':
      case 'B':
      case 'B-':
        return Colors.blue;
      case 'C+':
      case 'C':
      case 'C-':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  void _showGradeDialog(
    BuildContext context,
    TeacherDashboardViewModel viewModel,
    AssignmentModel assignment,
    String studentId,
    String studentName, {
    GradeModel? existingGrade,
  }) {
    final percentageController = TextEditingController(
      text: existingGrade?.percentage.toStringAsFixed(0) ?? '',
    );
    final feedbackController = TextEditingController(
      text: existingGrade?.feedback ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          existingGrade != null ? 'Update Grade' : 'Record Grade',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                studentName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                assignment.title,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: percentageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Percentage (0-100)',
                  border: OutlineInputBorder(),
                  suffixText: '%',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Feedback (Optional)',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 3,
                maxLength: 200,
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
            style: ElevatedButton.styleFrom(backgroundColor: primary),
            onPressed: () async {
              final percentageText = percentageController.text.trim();
              if (percentageText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a percentage'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final percentage = double.tryParse(percentageText);
              if (percentage == null || percentage < 0 || percentage > 100) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid percentage (0-100)'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              await viewModel.recordGrade(
                assignmentId: assignment.id,
                studentId: studentId,
                studentName: studentName,
                percentage: percentage,
                feedback: feedbackController.text.trim().isEmpty
                    ? null
                    : feedbackController.text.trim(),
              );

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      existingGrade != null
                          ? 'Grade updated successfully'
                          : 'Grade recorded successfully',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: Text(existingGrade != null ? 'Update' : 'Record'),
          ),
        ],
      ),
    );
  }
}
