import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studycompanion_app/viewmodels/teacher_dashboard_viewmodel.dart';
import 'package:studycompanion_app/models/assignment_model.dart';
import 'package:studycompanion_app/views/assignment_progress_page.dart';
import 'package:intl/intl.dart';

class TeacherAssignmentsPage extends StatefulWidget {
  const TeacherAssignmentsPage({super.key});

  @override
  State<TeacherAssignmentsPage> createState() => _TeacherAssignmentsPageState();
}

class _TeacherAssignmentsPageState extends State<TeacherAssignmentsPage> {
  static const primary = Color(0xFF631018);
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F9),
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text('Assignments', style: TextStyle(color: Colors.white)),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onSelected: (value) {
              setState(() => _selectedFilter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Assignments')),
              const PopupMenuItem(value: 'Active', child: Text('Active')),
              const PopupMenuItem(value: 'Overdue', child: Text('Overdue')),
              const PopupMenuItem(value: 'Due Soon', child: Text('Due Soon')),
            ],
          ),
        ],
      ),
      body: Consumer<TeacherDashboardViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final assignments = _getFilteredAssignments(viewModel);

          if (assignments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No assignments found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refreshData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return _buildAssignmentCard(context, assignment, viewModel);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final viewModel = context.read<TeacherDashboardViewModel>();
          _showCreateAssignmentDialog(context, viewModel);
        },
        backgroundColor: primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Assignment', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  List<AssignmentModel> _getFilteredAssignments(TeacherDashboardViewModel viewModel) {
    final assignments = viewModel.filteredAssignments;
    
    switch (_selectedFilter) {
      case 'Active':
        return assignments.where((a) => !a.isOverdue && a.submissionPercentage < 100).toList();
      case 'Overdue':
        return assignments.where((a) => a.isOverdue).toList();
      case 'Due Soon':
        return assignments.where((a) => a.isDueSoon && !a.isOverdue).toList();
      default:
        return assignments;
    }
  }

  Widget _buildAssignmentCard(
    BuildContext context,
    AssignmentModel assignment,
    TeacherDashboardViewModel viewModel,
  ) {
    final stats = viewModel.getAssignmentStats(assignment.id);
    final submissionPercentage = assignment.submissionPercentage;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showAssignmentDetailsModal(context, assignment, viewModel),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      assignment.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (assignment.isOverdue)
                    _buildStatusBadge('Overdue', Colors.red)
                  else if (assignment.isDueSoon)
                    _buildStatusBadge('Due Soon', Colors.orange)
                  else if (submissionPercentage >= 100)
                    _buildStatusBadge('Complete', Colors.green),
                ],
              ),
              const SizedBox(height: 8),
              
              // Subject and Class
              Row(
                children: [
                  Icon(Icons.subject, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    assignment.subject,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.class_, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      viewModel.getClassById(assignment.classId)?.name ?? 'Unknown Class',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Due Date
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: assignment.isOverdue ? Colors.red : Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Due: ${DateFormat('MMM dd, yyyy').format(assignment.dueDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: assignment.isOverdue ? Colors.red : Colors.grey[600],
                      fontWeight: assignment.isOverdue ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Submission Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Submissions: ${assignment.submittedCount}/${assignment.totalStudents}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    '${submissionPercentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(submissionPercentage),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: submissionPercentage / 100,
                backgroundColor: Colors.grey[200],
                color: _getProgressColor(submissionPercentage),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  void _showAssignmentDetailsModal(
    BuildContext context,
    AssignmentModel assignment,
    TeacherDashboardViewModel viewModel,
  ) {
    final stats = viewModel.getAssignmentStats(assignment.id);
    final classModel = viewModel.getClassById(assignment.classId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${assignment.subject} • ${classModel?.section ?? ''}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Details
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Description',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    assignment.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 20),
                  
                  _buildDetailRow('Class', classModel?.name ?? 'Unknown'),
                  _buildDetailRow('Subject', assignment.subject),
                  _buildDetailRow(
                    'Due Date',
                    DateFormat('MMMM dd, yyyy').format(assignment.dueDate),
                  ),
                  _buildDetailRow(
                    'Created',
                    DateFormat('MMM dd, yyyy').format(assignment.createdDate),
                  ),
                  _buildDetailRow(
                    'Submitted',
                    '${assignment.submittedCount}/${assignment.totalStudents}',
                  ),
                  _buildDetailRow(
                    'Submission Rate',
                    '${assignment.submissionPercentage.toStringAsFixed(1)}%',
                  ),
                  if (stats['averageScore'] != null && stats['averageScore'] > 0)
                    _buildDetailRow(
                      'Average Score',
                      '${stats['averageScore'].toStringAsFixed(1)}%',
                    ),
                  const SizedBox(height: 20),
                  
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeNotifierProvider.value(
                            value: viewModel,
                            child: AssignmentProgressPage(assignmentId: assignment.id),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.grading),
                    label: const Text('View Student Progress'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

  void _showCreateAssignmentDialog(BuildContext context, TeacherDashboardViewModel viewModel) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create Assignment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Assignment Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Due Date'),
                  subtitle: Text(DateFormat('MMMM dd, yyyy').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      selectedDate = picked;
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
                if (titleController.text.isEmpty || viewModel.selectedClassId.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                  return;
                }

                await viewModel.createAssignment(
                  classId: viewModel.selectedClassId,
                  title: titleController.text,
                  description: descController.text,
                  subject: viewModel.teacherSubject,
                  dueDate: selectedDate,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Assignment created successfully')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: primary),
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
