import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:studycompanion_app/viewmodels/student_dashboard_viewmodel.dart';
import 'package:studycompanion_app/viewmodels/announcement_viewmodel.dart';
import 'package:studycompanion_app/viewmodels/notification_viewmodel.dart';
import 'package:studycompanion_app/views/announcements_page.dart';
import 'package:studycompanion_app/views/notifications_page.dart';
import 'package:studycompanion_app/core/user_session.dart';
import 'package:studycompanion_app/views/edit_profile_page.dart';
import 'package:studycompanion_app/views/notification_settings_page.dart';
import 'package:studycompanion_app/viewmodels/login_viewmodel.dart';
import 'package:studycompanion_app/views/student_classes_page.dart';
import 'package:studycompanion_app/views/student_calendar_page.dart';
import 'dart:io';
import 'package:studycompanion_app/views/admin/firestore_inspector_page.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  static const primary = Color(0xFF800000);
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => StudentDashboardViewModel()),
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
        ChangeNotifierProvider(create: (_) => AnnouncementViewModel()),
      ],
      child: _buildScaffold(),
    );
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Handle navigation based on index
    switch (index) {
      case 0: // Dashboard - already here
        break;
      case 1: // Classes/Subjects
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentClassesPage()),
        );
        break;
      case 2: // Calendar
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const StudentCalendarPage()),
        );
        break;
      case 3: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfilePage()),
        );
        break;
    }
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final subjectController = TextEditingController();
    final dueDateController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (modalContext) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(modalContext).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add New Task',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Task Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dueDateController,
              decoration: const InputDecoration(labelText: 'Due Date'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(modalContext),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final title = titleController.text.trim();
                      final subject = subjectController.text.trim();
                      final dueDate = dueDateController.text.trim();
                      if (title.isEmpty || subject.isEmpty || dueDate.isEmpty) {
                        ScaffoldMessenger.of(modalContext).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill in all fields.'),
                          ),
                        );
                        return;
                      }
                      // Access ViewModel from the parent context
                      final viewModel = Provider.of<StudentDashboardViewModel>(
                        context,
                        listen: false,
                      );
                      viewModel.addTask(
                        title: title,
                        subject: subject,
                        dueDate: dueDate,
                      );
                      Navigator.pop(modalContext);
                    },
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Clear user session
              UserSession.name = '';
              UserSession.email = '';
              UserSession.role = '';
              // Navigate to login
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginViewModel()),
                (route) => false,
              );
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),

      // 🔝 HEADER
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfilePage()),
                );
                if (!mounted) return;
                setState(() {});
              },
              child: _buildProfileAvatar(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, ${UserSession.name.isNotEmpty ? UserSession.name.trim().split(RegExp(r'\\s+')).take(2).join(' ') : 'Student'}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const Text(
                    "STUDENT DASHBOARD",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  ).then((_) {
                    if (!mounted) return;
                    setState(() {});
                  });
                  break;
                case 'settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationSettingsPage(),
                    ),
                  );
                  break;
                case 'logout':
                  _logout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 12),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 12),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Consumer<NotificationViewModel>(
              builder: (context, notifyViewModel, _) {
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications, color: primary),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangeNotifierProvider.value(
                              value: notifyViewModel,
                              child: const NotificationsPage(),
                            ),
                          ),
                        );
                      },
                    ),
                    if (notifyViewModel.unreadCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            notifyViewModel.unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Consumer<StudentDashboardViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              children: [
                // 📊 PROGRESS CARD
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF800000), Color(0xFF5C0000)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Overall Academic Progress",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${viewModel.progressPercentage}%",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: viewModel.overallProgress,
                          backgroundColor: Colors.white24,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${viewModel.completedTasksCount} of ${viewModel.totalTasksCount} tasks completed",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ⏰ REMINDERS
                sectionTitle("Upcoming Reminders"),
                SizedBox(
                  height: 140,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: const [
                      ReminderCard("Physics Quiz", "Tomorrow, 10AM"),
                      ReminderCard("Science Club", "Wed, 3PM"),
                      ReminderCard("Return Books", "Fri, 5PM"),
                    ],
                  ),
                ),

                // � ANNOUNCEMENTS
                sectionTitle("Latest Announcements"),
                Consumer<AnnouncementViewModel>(
                  builder: (context, announcementViewModel, _) {
                    final announcements =
                        announcementViewModel.recentAnnouncements;
                    if (announcements.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'No announcements yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        ...announcements.take(2).map((announcement) {
                          final isRead = announcementViewModel.isRead(
                            announcement.id,
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  announcementViewModel.markAsRead(
                                    announcement.id,
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider.value(
                                            value: announcementViewModel,
                                            child: const AnnouncementsPage(),
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isRead
                                        ? Colors.grey[50]
                                        : Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border(
                                      left: BorderSide(
                                        color: isRead
                                            ? Colors.grey[400]!
                                            : Colors.blue[800]!,
                                        width: 4,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        announcement.title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        announcement.message,
                                        style: const TextStyle(fontSize: 12),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider.value(
                                        value: announcementViewModel,
                                        child: const AnnouncementsPage(),
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[800],
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            child: const Text('View All Announcements'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                // 🔔 NOTIFICATIONS
                sectionTitle("Recent Notifications"),
                Consumer<NotificationViewModel>(
                  builder: (context, notifyViewModel, _) {
                    final notifications = notifyViewModel.recentNotifications;
                    if (notifications.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'No notifications yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        ...notifications.take(3).map((notification) {
                          final iconData = _getNotificationIcon(
                            notification.notificationType,
                          );
                          final color = _getNotificationColor(
                            notification.notificationType,
                          );
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () {
                                  notifyViewModel.markAsRead(notification.id);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ChangeNotifierProvider.value(
                                            value: notifyViewModel,
                                            child: const NotificationsPage(),
                                          ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: notification.isRead
                                        ? Colors.grey[100]
                                        : Colors.amber[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: color.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Icon(
                                          iconData,
                                          color: color,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              notification.title,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              notification.body,
                                              style: const TextStyle(
                                                fontSize: 11,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChangeNotifierProvider.value(
                                        value: notifyViewModel,
                                        child: const NotificationsPage(),
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[800],
                              minimumSize: const Size(double.infinity, 40),
                            ),
                            child: const Text('View All Notifications'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                // �📚 TASKS
                sectionTitle("Assigned Tasks"),
                ...viewModel.tasks.map((task) => TaskTile(task: task)),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),

      // 🔻 BOTTOM NAV + FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: primary,
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(
                  Icons.dashboard,
                  color: _selectedIndex == 0 ? primary : Colors.grey,
                ),
                onPressed: () => _onNavItemTapped(0),
              ),
              IconButton(
                icon: Icon(
                  Icons.school,
                  color: _selectedIndex == 1 ? primary : Colors.grey,
                ),
                onPressed: () => _onNavItemTapped(1),
              ),
              const SizedBox(width: 40),
              IconButton(
                icon: Icon(
                  Icons.calendar_month,
                  color: _selectedIndex == 2 ? primary : Colors.grey,
                ),
                onPressed: () => _onNavItemTapped(2),
              ),
              IconButton(
                icon: Icon(
                  Icons.person,
                  color: _selectedIndex == 3 ? primary : Colors.grey,
                ),
                onPressed: () => _onNavItemTapped(3),
              ),
            ],
          ),
        ),
      ),
    );
  }

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

  Widget _buildProfileAvatar() {
    // Check if user has a profile image
    if (UserSession.profileImagePath.isNotEmpty) {
      // Load from file path
      return CircleAvatar(
        radius: 18,
        backgroundImage: FileImage(File(UserSession.profileImagePath)),
        backgroundColor: primary,
      );
    } else if (UserSession.name.isNotEmpty) {
      // Show initials
      String initials = _getInitials(UserSession.name);
      return CircleAvatar(
        radius: 18,
        backgroundColor: Color(UserSession.profileAvatarColor),
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else {
      // Default grey avatar
      return const CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person, color: Colors.white, size: 18),
      );
    }
  }

  String _getInitials(String name) {
    List<String> parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    // Get first letter of first name and last name
    return '${parts[0].substring(0, 1)}${parts[parts.length - 1].substring(0, 1)}'
        .toUpperCase();
  }

  // Helper method to get notification icon
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'task':
        return Icons.assignment;
      case 'achievement':
        return Icons.emoji_events;
      case 'announcement':
        return Icons.notifications_active;
      case 'alert':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  // Helper method to get notification color
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'task':
        return Colors.orange;
      case 'achievement':
        return Colors.green;
      case 'announcement':
        return Colors.blue;
      case 'alert':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// 🔹 Reminder Card
class ReminderCard extends StatelessWidget {
  final String title;
  final String time;
  const ReminderCard(this.title, this.time, {super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF800000);
    const gradientColor1 = Color(0xFF800000);
    const gradientColor2 = Color(0xFF5C0000);
    
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Show reminder details in a snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$title - $time'),
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'View Calendar',
                  onPressed: () {
                    // Navigate to calendar view
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StudentCalendarPage()),
                    );
                  },
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [gradientColor1, gradientColor2],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.schedule, color: Colors.white, size: 20),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
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
}

// 🔹 Task Tile
class TaskTile extends StatelessWidget {
  final dynamic task;

  const TaskTile({required this.task, super.key});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF800000);
    return Consumer<StudentDashboardViewModel>(
      builder: (context, viewModel, _) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: task.isCompleted ? Colors.green : Colors.grey,
            child: Icon(
              task.isCompleted ? Icons.check : Icons.book,
              color: Colors.white,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: Text(task.dueDate),
          onTap: () => _showEditTaskDialog(context, viewModel, task),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => viewModel.toggleTaskCompletion(task.id),
                child: Icon(
                  task.isCompleted
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: task.isCompleted ? primary : Colors.grey,
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showEditTaskDialog(context, viewModel, task);
                  } else if (value == 'delete') {
                    _confirmDelete(context, viewModel, task);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditTaskDialog(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    dynamic task,
  ) {
    final titleController = TextEditingController(text: task.title);
    final subjectController = TextEditingController(text: task.subject);
    final dueDateController = TextEditingController(text: task.dueDate);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dueDateController,
                decoration: const InputDecoration(labelText: 'Due Date'),
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
              final subject = subjectController.text.trim();
              final dueDate = dueDateController.text.trim();
              if (title.isEmpty || subject.isEmpty || dueDate.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields.')),
                );
                return;
              }
              viewModel.updateTask(
                task.copyWith(title: title, subject: subject, dueDate: dueDate),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    StudentDashboardViewModel viewModel,
    dynamic task,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              viewModel.deleteTask(task.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
