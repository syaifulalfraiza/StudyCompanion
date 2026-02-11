import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studycompanion_app/viewmodels/teacher_dashboard_viewmodel.dart';
import 'package:studycompanion_app/models/announcement_model.dart';

class TeacherAnnouncementsPage extends StatefulWidget {
  const TeacherAnnouncementsPage({super.key});

  @override
  State<TeacherAnnouncementsPage> createState() => _TeacherAnnouncementsPageState();
}

class _TeacherAnnouncementsPageState extends State<TeacherAnnouncementsPage> {
  static const primary = Color(0xFF631018);
  String _filterStatus = 'all'; // all, published, draft

  @override
  Widget build(BuildContext context) {
    return Consumer<TeacherDashboardViewModel>(
      builder: (context, viewModel, _) {
        final filteredAnnouncements = _getFilteredAnnouncements(viewModel);

        return Scaffold(
          backgroundColor: const Color(0xFFFCF9F9),
          appBar: AppBar(
            title: const Text('Manage Announcements'),
            backgroundColor: primary,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showCreateAnnouncementDialog(context, viewModel),
              ),
            ],
          ),
          body: Column(
            children: [
              // Filter Tabs
              Container(
                color: Colors.white,
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFilterTab('All', 'all', filteredAnnouncements.length),
                    ),
                    Expanded(
                      child: _buildFilterTab(
                        'Published',
                        'published',
                        viewModel.getAnnouncementsByStatus(true).length,
                      ),
                    ),
                    Expanded(
                      child: _buildFilterTab(
                        'Draft',
                        'draft',
                        viewModel.getAnnouncementsByStatus(false).length,
                      ),
                    ),
                  ],
                ),
              ),

              // Announcements List
              Expanded(
                child: filteredAnnouncements.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: () async {
                          await viewModel.refreshData();
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: filteredAnnouncements.length,
                          itemBuilder: (context, index) {
                            final announcement = filteredAnnouncements[index];
                            return _buildAnnouncementCard(
                              context,
                              viewModel,
                              announcement,
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<AnnouncementModel> _getFilteredAnnouncements(TeacherDashboardViewModel viewModel) {
    switch (_filterStatus) {
      case 'published':
        return viewModel.getAnnouncementsByStatus(true);
      case 'draft':
        return viewModel.getAnnouncementsByStatus(false);
      default:
        return viewModel.teacherAnnouncements;
    }
  }

  Widget _buildFilterTab(String label, String value, int count) {
    final isActive = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? primary : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                color: isActive ? primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.campaign_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No announcements yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first announcement',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    TeacherDashboardViewModel viewModel,
    AnnouncementModel announcement,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAnnouncementDetail(context, viewModel, announcement),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      announcement.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: announcement.isPublished
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      announcement.isPublished ? 'Published' : 'Draft',
                      style: TextStyle(
                        fontSize: 12,
                        color: announcement.isPublished ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Message Preview
              Text(
                announcement.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    announcement.formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    color: Colors.blue,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _showEditAnnouncementDialog(context, viewModel, announcement),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    color: Colors.red,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => _confirmDelete(context, viewModel, announcement),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnnouncementDetail(
    BuildContext context,
    TeacherDashboardViewModel viewModel,
    AnnouncementModel announcement,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(announcement.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: announcement.isPublished
                          ? Colors.green.withOpacity(0.1)
                          : Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      announcement.isPublished ? 'Published' : 'Draft',
                      style: TextStyle(
                        fontSize: 12,
                        color: announcement.isPublished ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    announcement.formattedDate,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(announcement.message),
              const SizedBox(height: 16),
              Text(
                'By: ${announcement.createdBy}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditAnnouncementDialog(context, viewModel, announcement);
            },
            child: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showCreateAnnouncementDialog(BuildContext context, TeacherDashboardViewModel viewModel) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    bool isPublished = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  maxLength: 500,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Publish immediately'),
                  value: isPublished,
                  onChanged: (value) {
                    setState(() => isPublished = value ?? true);
                  },
                  contentPadding: EdgeInsets.zero,
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
              onPressed: () {
                if (titleController.text.isNotEmpty && messageController.text.isNotEmpty) {
                  viewModel.createAnnouncement(
                    title: titleController.text,
                    message: messageController.text,
                    isPublished: isPublished,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(isPublished
                          ? 'Announcement published successfully'
                          : 'Announcement saved as draft'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAnnouncementDialog(
    BuildContext context,
    TeacherDashboardViewModel viewModel,
    AnnouncementModel announcement,
  ) {
    final titleController = TextEditingController(text: announcement.title);
    final messageController = TextEditingController(text: announcement.message);
    bool isPublished = announcement.isPublished;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Announcement'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  maxLength: 100,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: 'Message',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  maxLength: 500,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  title: const Text('Published'),
                  value: isPublished,
                  onChanged: (value) {
                    setState(() => isPublished = value ?? true);
                  },
                  contentPadding: EdgeInsets.zero,
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
              onPressed: () {
                if (titleController.text.isNotEmpty && messageController.text.isNotEmpty) {
                  viewModel.updateAnnouncement(
                    announcement.id,
                    title: titleController.text,
                    message: messageController.text,
                    isPublished: isPublished,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Announcement updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TeacherDashboardViewModel viewModel,
    AnnouncementModel announcement,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Announcement'),
        content: Text('Are you sure you want to delete "${announcement.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              viewModel.deleteAnnouncement(announcement.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Announcement deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
